-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true

local indent_group = vim.api.nvim_create_augroup("FiletypeIndent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.keymap.set("i", "<S-Tab>", "<C-d>", {
  desc = "Decrease indent",
})

local markdown_wrap_group = vim.api.nvim_create_augroup("MarkdownWrap", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = markdown_wrap_group,
  pattern = { "markdown", "mdx" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})
