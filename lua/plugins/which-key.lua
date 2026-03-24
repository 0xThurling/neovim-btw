local wk = require("which-key")

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your default settings here
	},
	config = function()
		wk.add({
			{ "<leader>c", group = "Code", desc = "Code" },
			{ "<leader>cf", desc = "Format file or range" },
			{ "<leader>ca", desc = "Code Actions" },
			{ "<leader>d", group = "Database", desc = "Database" },
			{ "<leader>e", desc = "Show diagnostics in a floating window" },
			{ "<leader>f", group = "Telescope", desc = "Telescope" },
			{ "<leader>fb", desc = "Find buffers" },
			{ "<leader>fc", desc = "Find string under cursor" },
			{ "<leader>fh", desc = "Find help tags" },
			{ "<leader>fr", desc = "Find recent files" },
			{ "<leader>fs", desc = "Find string in cwd" },
			{ "<leader>g", group = "Git", desc = "Git" },
			{ "<leader>gd", desc = "Go To Definition" },
			{ "<leader>gg", desc = "Open Lazygit" },
			{ "<leader>gf", desc = "Lazygit Filter" },
			{ "<leader>gF", desc = "Lazygit Filter Current File" },
			{ "<leader>gr", desc = "References" },
			{ "<leader>gi", desc = "Implementation" },
			{ "<leader>h", group = "Harpoon", desc = "Harpoon" },
			{ "<leader>h1", desc = "Harpoon mark 1" },
			{ "<leader>h2", desc = "Harpoon mark 2" },
			{ "<leader>h3", desc = "Harpoon mark 3" },
			{ "<leader>h4", desc = "Harpoon mark 4" },
			{ "<leader>hm", desc = "Harpoon menu" },
			{ "<leader>i", group = "Tools", desc = "Tools" },
			{ "<leader>io", desc = "Open Devdocs" },
			{ "<leader>r", group = "Rename", desc = "Rename" },
			{ "<leader>rn", desc = "Rename" },
			{ "<leader>rs", desc = "Restart Roslyn LSP Server" },
			{ "<leader>t", group = "Terminal", desc = "Terminal" },
			{ "<leader>to", desc = "Open floating terminal" },
			{ "<leader>x", group = "Diagnostics", desc = "Diagnostics" },
			{ "<leader>xd", desc = "Add diagnostics to loclist" },
		})
	end,
}