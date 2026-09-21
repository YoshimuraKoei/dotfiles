local transparent_groups = {
  "Normal",
  "NormalNC",
  "SignColumn",
  "EndOfBuffer",
  "LineNr",
  "CursorLineNr",
  "FoldColumn",
  "WinBar",
  "WinBarNC",
}

local function make_background_transparent()
  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

return {
  {
    "AstroNvim/astroui",
    opts = function(_, opts)
      opts.highlights = opts.highlights or {}
      opts.highlights.init = opts.highlights.init or {}

      for _, group in ipairs(transparent_groups) do
        opts.highlights.init[group] = vim.tbl_extend("force", opts.highlights.init[group] or {}, { bg = "NONE" })
      end
    end,
  },
  {
    "AstroNvim/astrotheme",
    init = function()
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        group = vim.api.nvim_create_augroup("ghostty_transparent_background", { clear = true }),
        callback = make_background_transparent,
      })
    end,
    opts = function(_, opts)
      opts.highlights = opts.highlights or {}
      opts.highlights.global = opts.highlights.global or {}

      for _, group in ipairs(transparent_groups) do
        opts.highlights.global[group] = vim.tbl_extend("force", opts.highlights.global[group] or {}, { bg = "NONE" })
      end
    end,
  },
}
