local M = {}

local state = {
  backend = nil,
  preview_pane_id = nil,
}

local image_formats_without_pdf = {
  "png",
  "jpg",
  "jpeg",
  "gif",
  "bmp",
  "webp",
  "tiff",
  "heic",
  "avif",
  "mp4",
  "mov",
  "avi",
  "mkv",
  "webm",
  "icns",
}

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = "PDF Preview" }) end

local function executable(name, fallback)
  if vim.fn.executable(name) == 1 then return name end
  if fallback and vim.fn.executable(fallback) == 1 then return fallback end
  return nil
end

local function wezterm_bin() return executable("wezterm", "/opt/homebrew/bin/wezterm") end

local function tmux_bin() return executable("tmux", "/opt/homebrew/bin/tmux") end

local function tdf_bin() return executable("tdf", vim.fn.expand("~/.cargo/bin/tdf")) end

local function shell_quote(value) return vim.fn.shellescape(value) end

local function is_pdf(path) return path and path:lower():sub(-4) == ".pdf" end

local function system_wait(cmd, opts)
  opts = vim.tbl_extend("force", { text = true }, opts or {})
  local result = vim.system(cmd, opts):wait()
  if result.code ~= 0 then
    return nil, vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
  end
  return result.stdout, nil
end

local function neo_tree_path()
  local ok, manager = pcall(require, "neo-tree.sources.manager")
  if not ok then return nil end

  local neo_state = manager.get_state_for_window()
  if not neo_state or not neo_state.tree then return nil end

  local node = neo_state.tree:get_node()
  if not node or not node.path or node.type == "directory" then return nil end

  return node.path
end

local function current_path()
  local path = neo_tree_path()
  if path then return vim.fn.fnamemodify(path, ":p") end

  path = vim.api.nvim_buf_get_name(0)
  if path == "" then return nil end
  return vim.fn.fnamemodify(path, ":p")
end

local function resolve_pdf_path(arg)
  local path = arg and arg ~= "" and vim.fn.fnamemodify(vim.fn.expand(arg), ":p") or current_path()
  if not path then
    notify("Open a PDF buffer, select a PDF in neo-tree, or run :PdfPreview path/to/file.pdf", vim.log.levels.WARN)
    return nil
  end
  if not is_pdf(path) then
    notify("PDF file only: " .. path, vim.log.levels.ERROR)
    return nil
  end
  if vim.fn.filereadable(path) == 0 then
    notify("File not found: " .. path, vim.log.levels.ERROR)
    return nil
  end
  return path
end

local function backend()
  if vim.env.WEZTERM_PANE and wezterm_bin() then return "wezterm" end
  return nil
end

local function missing_backend_message()
  if vim.env.TERM_PROGRAM == "ghostty" or vim.env.TERM_PROGRAM == "Ghostty" then
    return "Ghostty cannot be controlled like WezTerm. Use WezTerm for automatic tdf PDF preview."
  end
  return "Start nvim inside WezTerm or inside tmux to use the tdf PDF preview."
end

local WezTerm = {}

function WezTerm.pane_exists(pane_id)
  if not pane_id then return false end

  local wezterm = wezterm_bin()
  if not wezterm then return false end

  local stdout = system_wait({ wezterm, "cli", "list", "--format=json" })
  if not stdout then return false end

  local ok, panes = pcall(vim.json.decode, stdout)
  if not ok then return false end

  for _, pane in ipairs(panes or {}) do
    if tostring(pane.pane_id) == tostring(pane_id) then return true end
  end
  return false
end

function WezTerm.send_text(pane_id, text)
  local wezterm = wezterm_bin()
  local _, err = system_wait({ wezterm, "cli", "send-text", "--no-paste", "--pane-id=" .. pane_id, text })
  if err then
    notify(err, vim.log.levels.ERROR)
    return false
  end
  return true
end

function WezTerm.split()
  local wezterm = wezterm_bin()
  local stdout, err = system_wait({
    wezterm,
    "cli",
    "split-pane",
    "--right",
    "--percent=50",
    "--",
    vim.o.shell or "zsh",
    "-l",
  })
  if err then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  local pane_id = tonumber(vim.trim(stdout or ""))
  if not pane_id then
    notify("Failed to create WezTerm preview pane.", vim.log.levels.ERROR)
    return nil
  end
  return tostring(pane_id)
end

function WezTerm.ensure()
  if state.backend == "wezterm" and WezTerm.pane_exists(state.preview_pane_id) then return state.preview_pane_id end
  state.backend = "wezterm"
  state.preview_pane_id = WezTerm.split()
  return state.preview_pane_id
end

function WezTerm.open(path, tdf)
  local pane_id = WezTerm.ensure()
  if not pane_id then return end

  WezTerm.send_text(pane_id, "q")
  vim.wait(80)
  WezTerm.send_text(pane_id, "\3")
  vim.wait(80)

  local cmd = ("clear; %s %s\n"):format(shell_quote(tdf), shell_quote(path))
  if WezTerm.send_text(pane_id, cmd) then
    system_wait({ wezterm_bin(), "cli", "activate-pane", "--pane-id=" .. vim.env.WEZTERM_PANE })
  end
end

function WezTerm.send_key(key)
  if not WezTerm.pane_exists(state.preview_pane_id) then
    notify("No WezTerm PDF preview pane is open.", vim.log.levels.WARN)
    return
  end
  WezTerm.send_text(state.preview_pane_id, key)
end

function WezTerm.close()
  if not WezTerm.pane_exists(state.preview_pane_id) then
    state.preview_pane_id = nil
    return
  end
  system_wait({ wezterm_bin(), "cli", "kill-pane", "--pane-id=" .. state.preview_pane_id })
  state.preview_pane_id = nil
end

local Tmux = {}

function Tmux.pane_exists(pane_id)
  if not pane_id then return false end
  local stdout = system_wait({ tmux_bin(), "list-panes", "-F", "#{pane_id}" })
  if not stdout then return false end
  for pane in stdout:gmatch("[^\r\n]+") do
    if pane == pane_id then return true end
  end
  return false
end

function Tmux.configure_passthrough()
  -- Needed for Kitty graphics protocol passthrough in Ghostty.
  system_wait({ tmux_bin(), "set-option", "-g", "allow-passthrough", "on" })
end

function Tmux.split(path, tdf)
  Tmux.configure_passthrough()

  local command = ("exec %s -f %s"):format(shell_quote(tdf), shell_quote(path))
  local stdout, err = system_wait({
    tmux_bin(),
    "split-window",
    "-h",
    "-p",
    "50",
    "-P",
    "-F",
    "#{pane_id}",
    command,
  })
  if err then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  local pane_id = vim.trim(stdout or "")
  if pane_id == "" then
    notify("Failed to create tmux preview pane.", vim.log.levels.ERROR)
    return nil
  end
  return pane_id
end

function Tmux.open(path, tdf)
  if state.backend == "tmux" and Tmux.pane_exists(state.preview_pane_id) then
    system_wait({ tmux_bin(), "kill-pane", "-t", state.preview_pane_id })
  end

  state.backend = "tmux"
  state.preview_pane_id = Tmux.split(path, tdf)
end

function Tmux.send_key(key)
  if not Tmux.pane_exists(state.preview_pane_id) then
    notify("No tmux PDF preview pane is open.", vim.log.levels.WARN)
    return
  end
  system_wait({ tmux_bin(), "send-keys", "-t", state.preview_pane_id, key })
end

function Tmux.close()
  if Tmux.pane_exists(state.preview_pane_id) then
    system_wait({ tmux_bin(), "kill-pane", "-t", state.preview_pane_id })
  end
  state.preview_pane_id = nil
end

function M.open(arg)
  local active_backend = backend()
  if not active_backend then
    notify(missing_backend_message(), vim.log.levels.ERROR)
    return
  end

  local tdf = tdf_bin()
  if not tdf then
    notify("tdf is not installed. Expected ~/.cargo/bin/tdf or a tdf in PATH.", vim.log.levels.ERROR)
    return
  end

  local path = resolve_pdf_path(arg)
  if not path then return end

  WezTerm.open(path, tdf)
end

local function send_tdf_key(key)
  local active_backend = state.backend or backend()
  if active_backend ~= "wezterm" then
    notify(missing_backend_message(), vim.log.levels.ERROR)
    return
  end
  WezTerm.send_key(key)
end

function M.next_page() send_tdf_key("l") end

function M.prev_page() send_tdf_key("h") end

function M.fullscreen() send_tdf_key("f") end

function M.invert() send_tdf_key("i") end

function M.close()
  if state.backend == "wezterm" then
    WezTerm.close()
  elseif state.backend == "tmux" then
    Tmux.close()
  else
    state.preview_pane_id = nil
  end
  state.backend = nil
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      -- Do not let snacks try to open PDFs. PDFs are handled by tdf in a WezTerm/tmux pane.
      opts.image = opts.image or {}
      opts.image.formats = image_formats_without_pdf
    end,
  },
  {
    "AstroNvim/astrocore",
    init = function()
      vim.api.nvim_create_user_command("PdfPreview", function(opts) M.open(opts.args) end, {
        nargs = "?",
        complete = "file",
        desc = "Open a PDF preview in a WezTerm or tmux pane with tdf",
      })
      vim.api.nvim_create_user_command("PdfPreviewNext", M.next_page, {
        desc = "Go to the next page in the tdf preview",
      })
      vim.api.nvim_create_user_command("PdfPreviewPrev", M.prev_page, {
        desc = "Go to the previous page in the tdf preview",
      })
      vim.api.nvim_create_user_command("PdfPreviewFullScreen", M.fullscreen, {
        desc = "Toggle fullscreen in the tdf preview",
      })
      vim.api.nvim_create_user_command("PdfPreviewInvert", M.invert, {
        desc = "Invert colors in the tdf preview",
      })
      vim.api.nvim_create_user_command("PdfPreviewClose", M.close, {
        desc = "Close the PDF preview pane",
      })
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "*.pdf",
        callback = function(args)
          vim.bo[args.buf].buftype = "nofile"
          vim.bo[args.buf].swapfile = false
          vim.bo[args.buf].modifiable = true
          vim.bo[args.buf].filetype = "pdf"
          vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, {
            "# PDF",
            "",
            "Use `:PdfPreview` from WezTerm to open this PDF in tdf.",
            "Ghostty cannot run the automatic pane preview workflow.",
          })
          vim.bo[args.buf].modifiable = false
          vim.bo[args.buf].modified = false
          M.open(args.file)
        end,
      })
    end,
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}

      opts.mappings.n["<Leader>P"] = { function() M.open() end, desc = "Preview current PDF" }
      opts.mappings.n["<Leader>]p"] = { M.next_page, desc = "PDF next page" }
      opts.mappings.n["<Leader>[p"] = { M.prev_page, desc = "PDF previous page" }
      opts.mappings.n["<Leader>pf"] = { M.fullscreen, desc = "PDF fullscreen" }
      opts.mappings.n["<Leader>pi"] = { M.invert, desc = "PDF invert colors" }
      opts.mappings.n["<Leader>pc"] = { M.close, desc = "Close PDF preview" }
    end,
  },
}
