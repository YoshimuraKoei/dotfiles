local web_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
    },

    format_on_save = function(bufnr)
      if not web_filetypes[vim.bo[bufnr].filetype] then
        return
      end

      return {
        timeout_ms = 2000,
        lsp_format = "never",
      }
    end,
    },
  },
}
