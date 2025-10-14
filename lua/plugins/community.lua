return {
  {'aliqyan-21/darkvoid.nvim'},
  {
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},
	{

		"tris203/rzls.nvim",
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				cs = { "csharpier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				go = { "gofmt", "goimports" },
			},
		},
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"m4xshen/autoclose.nvim",
		event = "InsertEnter",
		config = function()
			require("autoclose").setup({
				keys = {
					["("] = { escape = false, close = true, pair = "()" },
					["["] = { escape = false, close = true, pair = "[]" },
					["{"] = { escape = false, close = true, pair = "{}" },
					['"'] = { escape = true, close = true, pair = '""' },
					["'"] = { escape = true, close = true, pair = "''" },
					["`"] = { escape = true, close = true, pair = "``" },
				},
				options = {
					disabled_filetypes = { "text" },
					disable_when_touch = false,
					pair_spaces = false,
					auto_indent = true,
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
}
