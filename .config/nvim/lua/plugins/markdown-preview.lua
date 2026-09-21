return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && ./install.sh",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "light"
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown preview" },
    },
  },
}
