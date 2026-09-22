---@type LazySpec
return {
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      if vim.fn.has "macunix" == 1 then vim.g.vimtex_view_method = "skim" end
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    keys = {
      {
        "<C-k>",
        function()
          local luasnip = require "luasnip"
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
            return ""
          end
          return "\t"
        end,
        mode = { "i", "s" },
        expr = true,
        silent = true,
        desc = "Expand or jump snippet",
      },
      {
        "<C-j>",
        function()
          local luasnip = require "luasnip"
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
            return ""
          end
          return ""
        end,
        mode = { "i", "s" },
        expr = true,
        silent = true,
        desc = "Jump to previous snippet node",
      },
    },
    opts = function(_, opts)
      opts = opts or {}
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load {
        paths = vim.fn.stdpath "config" .. "/LuaSnip",
      }
      return opts
    end,
  },
}
