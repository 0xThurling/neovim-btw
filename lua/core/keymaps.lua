local function open_floating_terminal()
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	})
	vim.fn.termopen(vim.o.shell)
	vim.cmd("startinsert")
end

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 500,
	})
end, { desc = "Format file or range (in visual mode)" })

vim.keymap.set({ "n" }, "<leader>cc", function()
	vim.cmd("Codeium Chat")
end, { desc = "Opens Codeium Chat for the current buffer" })

vim.keymap.set(
	{ "n" },
	"<leader>to",
	open_floating_terminal,
	{ noremap = true, silent = true, desc = "Open floating terminal" }
)
