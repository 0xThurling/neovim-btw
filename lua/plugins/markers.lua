return {
	{
		"jameswolensky/marker-groups.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required
			-- Optional pickers:
			-- "ibhagwan/fzf-lua",
			-- "folke/snacks.nvim",
			-- "nvim-mini/mini.nvim",
			-- "nvim-telescope/telescope.nvim",
		},
		config = function()
			require("marker-groups").setup({
				-- Your configuration here
			})
		end,
	},
}
