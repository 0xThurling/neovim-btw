return {
	"rafamadriz/friendly-snippets",
	config = function()
		require("luasnip.loaders.from_vscode").lazy_load()
		require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/lua/custom/snippets" } })
		require("luasnip").filetype_extend("ruby", { "rails" })
		require("luasnip").filetype_extend("eruby", { "html", "ruby" })
	end,
}