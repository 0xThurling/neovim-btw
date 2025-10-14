return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local lspconfig = vim.lsp.config
			local util = lspconfig.util
			local lsp_utils = require("core.lsp_utils")
			local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
			function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				if syntax == "" or syntax == nil then
					syntax = "markdown"
				  end	
				return orig_util_open_floating_preview(contents, syntax, opts, ...)
			end
			local _ = require("cmp_nvim_lsp").default_capabilities({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"gopls",
					"html",
					"clangd",
					"pyright",
					"sqlls",
					"rust_analyzer",
					"asm_lsp",
					"angularls",
					"bashls",
					"svelte",
					"cssls",
					"herb_ls",
				},
				automatic_installation = true,
				handlers = {
					function(server_name)
						require("mason-lspconfig").setup({
							capabilities = capabilities,
							on_attach = lsp_utils.on_attach,
						})
					end,
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							on_attach = lsp_utils.on_attach,
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
					end,
					["herb_ls"] = function()
						if not lspconfig.configs.herb_ls then
							lspconfig.configs.herb_ls = {
								default_config = {
									cmd = { "herb-language-server", "--stdio" },
									filetypes = { "eruby", "html.erb" },
									root_dir = util.root_pattern("Gemfile", ".git", "."),
									settings = {},
								},
							}
						end
						lspconfig.herb_ls.setup({
							capabilities = capabilities,
							on_attach = lsp_utils.on_attach,
						})
					end,
				}
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
					"*.rb",
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
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
}
