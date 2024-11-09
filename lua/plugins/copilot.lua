return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken",
		opts = {
			debug = true,
			window = {
				layout = "float",
				relative = "cursor",
				width = 1,
				height = 0.4,
				row = 1,
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")

			chat.setup(opts)

			-- Create commands for visual and buffer modes
			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, { selection = select.visual })
			end, { nargs = "*", range = true })

			vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
				chat.ask(args.args, { selection = select.buffer })
			end, { nargs = "*", range = true })

			-- Keymaps
			vim.keymap.set("n", "<leader>po", ":CopilotChatBuffer<CR>", { desc = "Open CopilotChat with buffer" })
			vim.keymap.set("v", "<leader>po", ":CopilotChatVisual<CR>", { desc = "Open CopilotChat with selection" })

			vim.keymap.set("n", "<leader>pe", ":CopilotChatBuffer explain<CR>", { desc = "Explain buffer" })
			vim.keymap.set("v", "<leader>pe", ":CopilotChatVisual explain<CR>", { desc = "Explain selection" })

			vim.keymap.set("n", "<leader>pd", ":CopilotChatBuffer docs<CR>", { desc = "Document buffer" })
			vim.keymap.set("v", "<leader>pd", ":CopilotChatVisual docs<CR>", { desc = "Document selection" })
		end,
	},
}
