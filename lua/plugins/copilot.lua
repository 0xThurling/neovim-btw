return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
      { "MeanderingProgrammer/render-markdown.nvim" }, -- Add this line
		},
		build = "make tiktoken",
		opts = {
			debug = true,
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")

			chat.setup(opts)

			-- Create commands for visual and buffer modes
			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, { selection = select.visual, popup=true })
				vim.cmd("vertical resize -15")  -- Adjust the height of the window
			end, { nargs = "*", range = true })

      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
				chat.ask(args.args, { selection = select.visual, popup=true })
				vim.cmd("vertical resize -15")  -- Adjust the height of the window
			end, { nargs = "*", range = true })

			-- Keymaps
			vim.keymap.set("n", "<leader>po", ":CopilotChatBuffer<CR>", { desc = "Open CopilotChat with buffer" })
			vim.keymap.set("v", "<leader>po", ":CopilotChatVisual<CR>", { desc = "Open CopilotChat with selection" })

			vim.keymap.set("n", "<leader>pe", ":CopilotChatBuffer explain<CR>", { desc = "Explain buffer" })
			vim.keymap.set("v", "<leader>pe", ":CopilotChatVisual explain<CR>", { desc = "Explain selection" })

			vim.keymap.set("n", "<leader>pd", ":CopilotChatBuffer docs<CR>", { desc = "Document buffer" })
			vim.keymap.set("v", "<leader>pd", ":CopilotChatVisual docs<CR>", { desc = "Document selection" })

      -- Registers copilot-chat filetype for markdown rendering
      require('render-markdown').setup({
        file_types = { 'markdown', 'copilot-chat' },
      })

      -- You might also want to disable default header highlighting 
      -- for copilot chat when doing this and set error header style and separator
      require('CopilotChat').setup({
        highlight_headers = false,
        separator = '---',
        error_header = '> [!ERROR] Error',
        -- rest of your config
      })
		end,
	},
}
