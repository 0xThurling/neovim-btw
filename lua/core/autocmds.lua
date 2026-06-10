-- C/C++ autocmds: compile_commands.json detection
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    -- Notify if compile_commands.json is found so clangd can index properly
    -- Set useful options for low-level C++ editing
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"  -- visual column guide at 100 chars
  end,
})

-- Assembly files: sensible defaults
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "asm", "nasm", "gas" },
  callback = function()
    vim.opt_local.tabstop = 8
    vim.opt_local.shiftwidth = 8
    vim.opt_local.expandtab = false
    vim.opt_local.colorcolumn = ""
  end,
})
