local on_attach = function (client, bufnr)
  local opts = {noremap = true, silent = true, buffer = bufnr}

  -- Go to definition
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)

  -- Go to implementation
  vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)

  -- You can add more LSP-related keybindings here
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
end

return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "ts_ls", "gopls", "html" },
				automatic_installation = true,
			})

			-- Configure lua_ls
			require("lspconfig").lua_ls.setup({
				capabilities = capabilities,
        on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
						},
					},
				},
			})

			-- Configure tsserver
			require("lspconfig").ts_ls.setup({
				capabilities = capabilities,
        on_attach = on_attach,
			})

			-- Configure gopls
			require("lspconfig").gopls.setup({
				capabilities = capabilities,
        on_attach = on_attach,
			})

			-- Configure HTML
			require("lspconfig").html.setup({
				capabilities = capabilities,
        on_attach = on_attach,
				filetypes = { "html", "htmldjango" },
			})

			-- Setup Lua LSP Server
			vim.api.nvim_create_autocmd({ "BufEnter" }, {
				pattern = { "*.lua", "*.ts", "*.tsx", "*.js", "*.jsx", "*.go", "*.html" },
				callback = function(event)
					local filetype = vim.bo[event.buf].filetype
					if filetype == "lua" then
						vim.cmd("LspStart lua_ls")
					elseif
						filetype == "typescript"
						or filetype == "javascript"
						or filetype == "typescriptreact"
						or filetype == "javascriptreact"
					then
						vim.cmd("LspStart ts_ls")
					elseif filetype == "go" then
						vim.cmd("LspStart gopls")
					elseif filetype == "html" then
						vim.cmd("LspStart html")
					end
				end,
			})

			-- Setup the Error float window
			vim.diagnostic.config({
				virtual_text = false,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
}
