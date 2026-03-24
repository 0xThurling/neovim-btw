return {
	"mg979/vim-visual-multi",
	branch = "master",
	event = "VeryLazy",
	config = function()
		vim.g.VM_default_options = {
			show_cursor_words = true,
			highlight_symbols = true,
		}
		vim.keymap.set({ "n", "x" }, "<S-M-v>", "<C-v>", { desc = "Visual block mode" })
	end,
}