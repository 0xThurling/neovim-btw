return {
	{
		"simrat39/rust-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local rust_tools = require("rust-tools")
			local dap = require("dap")
			local mason_nvim_dap = require("mason-nvim-dap")

			-- Initialize Mason
			mason.setup({
				ensure_installed = {
					"csharpier", -- for formatting
				},
			})
			mason_lspconfig.setup({
				ensure_installed = { "rust_analyzer" },
			})
			mason_nvim_dap.setup({
				ensure_installed = { "codelldb", "rdbg", "netcoredbg" },
				handlers = {},
			})

			-- C# DAP configuration
			dap.adapters.coreclr = {
				type = "executable",
				command = vim.fn.exepath("netcoredbg"),
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll or exe: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
				},
			}

			-- Ruby DAP configuration
			dap.adapters.rdbg = {
				type = "executable",
				command = "rdbg",
				args = { "--open", "--port=${port}", "-c", "--", "bundle", "exec", "rails", "server" },
			}

			dap.configurations.ruby = {
				{
					type = "rdbg",
					request = "launch",
					name = "Launch Rails",
					program = "${workspaceFolder}/bin/rails",
					args = { "server" },
					useBundler = true,
				},
				{
					type = "rdbg",
					request = "attach",
					name = "Attach to Rails",
					remoteHost = "127.0.0.1",
					remotePort = "3000",
					remoteWorkspace = "${workspaceFolder}",
				},
			}

			-- Get codelldb paths dynamically
			local mason_registry = require("mason-registry")
			local codelldb = mason_registry.get_package("codelldb")
			local extension_path = codelldb:get_install_path()
			local codelldb_path = extension_path .. "/extension/adapter/codelldb"

			-- Set liblldb_path based on OS
			local liblldb_path
			if vim.fn.has("mac") == 1 then
				liblldb_path = extension_path .. "/extension/lldb/lib/liblldb.dylib"
			elseif vim.fn.has("unix") == 1 then
				liblldb_path = extension_path .. "/extension/lldb/lib/liblldb.so"
			elseif vim.fn.has("win32") == 1 then
				liblldb_path = extension_path .. "/extension/lldb/bin/liblldb.dll"
			else
				error("Unsupported operating system for codelldb")
			end

			-- Setup rust-tools with debugger config
			rust_tools.setup({
				server = {
					on_attach = function(_, bufnr)
						-- Rust-specific keymaps
						vim.keymap.set(
							"n",
							"<leader>ph",
							rust_tools.hover_actions.hover_actions,
							{ buffer = bufnr, desc = "Rust Hover Actions" }
						)
						vim.keymap.set(
							"n",
							"<leader>pa",
							rust_tools.code_action_group.code_action_group,
							{ buffer = bufnr, desc = "Rust Code Actions" }
						)

						-- Generic LSP keymaps
						local opts = { noremap = true, silent = true, buffer = bufnr }
						vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
						vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
						vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
						vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
						vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
					end,
				},
				dap = {
					adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
				},
			})

			-- Setup nvim-dap-ui for debugging UI
			local dapui = require("dapui")
			dapui.setup()

			-- Automatically open/close DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Keymaps for debugging with leader key
			local keymap_opts = { noremap = true, silent = true }
			vim.keymap.set(
				"n",
				"<leader>pc",
				dap.continue,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Continue" })
			)
			vim.keymap.set(
				"n",
				"<leader>so",
				dap.step_over,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Step Over" })
			)
			vim.keymap.set(
				"n",
				"<leader>si",
				dap.step_into,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Step Into" })
			)
			vim.keymap.set(
				"n",
				"<leader>sO",
				dap.step_out,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Step Out" })
			)
			vim.keymap.set(
				"n",
				"<leader>pb",
				dap.toggle_breakpoint,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Toggle Breakpoint" })
			)
			vim.keymap.set(
				"n",
				"<leader>pr",
				dap.repl.toggle,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Toggle REPL" })
			)
			vim.keymap.set(
				"n",
				"<leader>pu",
				dapui.toggle,
				vim.tbl_extend("force", keymap_opts, { desc = "Debug: Toggle DAP UI" })
			)
		end,
	},
}

