local M = {}

M.on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Go to definition
	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)

	-- Go to implementation
	vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)

	-- You can add more LSP-related keybindings here
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

	-- Disable diagnostics for asm_lsp
	if client.name == "asm_lsp" then
		vim.diagnostic.config({
			virtual_text = false,
			signs = false,
			underline = false,
			update_in_insert = false,
			severity_sort = false,
		}, bufnr)
	end
end

return M
