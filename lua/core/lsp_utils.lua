local M = {}

M.on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Enable inlay hints if supported (Neovim 0.10+, clangd, rust-analyzer, etc.)
	if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	-- Go to definition
	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)

	-- Go to implementation
	vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)

	-- You can add more LSP-related keybindings here
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
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
