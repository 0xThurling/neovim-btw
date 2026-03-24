return {
	"emmanueltouzery/apidocs.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {},
	config = function()
		require("apidocs").setup({})
	end,
}