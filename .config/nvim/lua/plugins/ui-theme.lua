local sidebar_bg = "#0f1320"
local sidebar_bg_alt = "#1f2a44"
local status_bg = "#0b1020"
local tab_bg = "#111827"
local tab_active_bg = "#25324d"
local status_accent = "#7fb4ff"
local status_accent_2 = "#e6c36a"
local text = "#d8dee9"
local muted = "#8b93a6"
local blue = "#82b8ff"
local yellow = "#e6c36a"

local highlights = {
  NeoTreeNormal = { bg = sidebar_bg, fg = text },
  NeoTreeNormalNC = { bg = sidebar_bg, fg = muted },
  NeoTreeEndOfBuffer = { bg = sidebar_bg, fg = sidebar_bg },
  NeoTreeCursorLine = { bg = sidebar_bg_alt },
  NeoTreeWinSeparator = { bg = sidebar_bg, fg = "#252b3a" },
  NeoTreeRootName = { bg = sidebar_bg, fg = text, bold = true },
  NeoTreeDirectoryIcon = { bg = sidebar_bg, fg = blue },
  NeoTreeDirectoryName = { bg = sidebar_bg, fg = blue },
  NeoTreeFileName = { bg = sidebar_bg, fg = text },
  NeoTreeFileNameOpened = { bg = sidebar_bg, fg = yellow, bold = true },
  NeoTreeIndentMarker = { bg = sidebar_bg, fg = "#3a4052" },
  NeoTreeGitAdded = { bg = sidebar_bg, fg = "#8fbc8f" },
  NeoTreeGitModified = { bg = sidebar_bg, fg = yellow },
  NeoTreeGitDeleted = { bg = sidebar_bg, fg = "#d08770" },
  NeoTreeFloatBorder = { bg = sidebar_bg, fg = blue },
  NeoTreeFloatTitle = { bg = sidebar_bg, fg = yellow, bold = true },

  StatusLine = { bg = status_bg, fg = text },
  StatusLineNC = { bg = status_bg, fg = muted },
  HeirlineNormal = { bg = status_bg, fg = text },
  HeirlineInactive = { bg = status_bg, fg = muted },
  HeirlineInsert = { bg = "#a3be8c", fg = "#10131a", bold = true },
  HeirlineVisual = { bg = status_accent_2, fg = "#10131a", bold = true },
  HeirlineReplace = { bg = "#d08770", fg = "#10131a", bold = true },
  HeirlineCommand = { bg = "#b48ead", fg = "#10131a", bold = true },
  HeirlineTerminal = { bg = "#8fbcbb", fg = "#10131a", bold = true },

  TabLine = { bg = tab_bg, fg = muted },
  TabLineFill = { bg = tab_bg, fg = muted },
  TabLineSel = { bg = tab_active_bg, fg = text, bold = true },

  WinSeparator = { bg = "NONE", fg = "#252b3a" },
}

local function apply_highlights()
  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
end

return {
  {
    "AstroNvim/astroui",
    init = function()
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        group = vim.api.nvim_create_augroup("custom_ui_theme_highlights", { clear = true }),
        callback = apply_highlights,
      })
    end,
    opts = function(_, opts)
      opts.highlights = opts.highlights or {}
      opts.highlights.init = vim.tbl_deep_extend("force", opts.highlights.init or {}, highlights)
      opts.status = opts.status or {}
      opts.status.colors = vim.tbl_deep_extend("force", opts.status.colors or {}, {
        bg = status_bg,
        section_bg = status_bg,
        buffer_bg = tab_bg,
        buffer_active_bg = tab_active_bg,
        buffer_visible_bg = tab_bg,
        tabline_bg = tab_bg,
        normal = status_accent,
        insert = "#a3be8c",
        visual = status_accent_2,
        replace = "#d08770",
        command = "#b48ead",
        terminal = "#8fbcbb",
        scrollbar = status_accent_2,
      })
    end,
  },
}
