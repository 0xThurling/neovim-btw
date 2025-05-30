local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Go to definition
	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)

	-- Go to implementation
	vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)

	-- You can add more LSP-related keybindings here
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
end

return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"gopls",
					"html",
					"omnisharp",
					"clangd",
					"pyright",
					"sqlls",
					"rust_analyzer",
					"asm_lsp",
					"angularls",
					"bashls",
          "svelte",
          "cssls"
				},
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

			-- CSS LSP
			require("lspconfig").cssls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Bash LSP
			require("lspconfig").bashls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Svelte LSP
			require("lspconfig").svelte.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Angular Language Server
			require("lspconfig").angularls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
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

			require("lspconfig").omnisharp.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
			})

			-- Configure clangd for C++
			require("lspconfig").clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "clangd", "--background-index" },
				root_dir = require("lspconfig").util.root_pattern("compile_commands.json", ".clangd"),
			})

			-- Configure pyright for Python
			require("lspconfig").pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure sqlls for SQL
			require("lspconfig").sqlls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure ZIG lsp
			require("lspconfig").zls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Add this configuration for rust_analyzer
			require("lspconfig").rust_analyzer.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			require("lspconfig").ols.setup({
				init_options = {
					checker_args = "-strict-style",
					collections = {
						{ name = "shared", path = vim.fn.expand("$HOME/odin") },
					},
				},
			})

			-- Add this configuration for asm_lsp
			require("lspconfig").asm_lsp.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Setup Lua LSP Server
			vim.api.nvim_create_autocmd({ "BufEnter" }, {
				pattern = {
					"*.lua",
					"*.ts",
					"*.tsx",
					"*.js",
					"*.jsx",
					"*.go",
					"*.html",
					"*.cs",
					"*.py",
					"*.c",
					"*.h",
					"*.cpp",
					"*.rs",
					"*.asm",
          "*.sh",
          "*.svelte",
          "*.css",
				},
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
					elseif filetype == "cs" then
						vim.cmd("LspStart omnisharp")
					elseif filetype == "cpp" or filetype == "c" then
						vim.cmd("LspStart clangd")
					elseif filetype == "python" then
						vim.cmd("LspStart pylsp")
					elseif filetype == "sql" then
						vim.cmd("LspStart sqlls")
					elseif filetype == "odin" then
						vim.cmd("LspStart ols")
					elseif filetype == "rust" then
						vim.cmd("LspStart rust_analyzer")
					elseif filetype == "asm" then
						vim.cmd("LspStart asm_lsp")
					elseif filetype == "sh" then
						vim.cmd("LspStart bashls")
					elseif filetype == "svelte" then
						vim.cmd("LspStart svelte")
					elseif filetype == "css" then
						vim.cmd("LspStart cssls")
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
