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

vim.keymap.set(
	{ "n" },
	"<leader>to",
	open_floating_terminal,
	{ noremap = true, silent = true, desc = "Open floating terminal" }
)

vim.keymap.set("n", "<Tab>q", ":q!<CR>", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Force quit current window", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<Tab>s", ":vsplit<CR>", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Split current buffer vertically", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<Tab>h", "<C-w>h", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Move to the left buffer", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<Tab>l", "<C-w>l", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Move to the right buffer", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<Tab>j", "<C-w>j", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Move to the bottom buffer", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<Tab>k", "<C-w>k", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Move to the top buffer", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<C-s>", ":wa<CR>", {
	noremap = true,
	silent = true, -- Optional: makes the command silent (no feedback in command line)
	desc = "Save all buffers", -- Optional: adds a description for :h keymap
})

vim.keymap.set("n", "<esc><esc>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlighting" })

-- Open dadbod
vim.keymap.set("n", "<leader>d", ":DBUI<CR>", { desc = "Open Dadbod" })

vim.keymap.set('t', '<esc>', "<C-\\><C-n>", { desc = 'Exit Terminal Mode' })

vim.keymap.set("i", "<M-Backspace>", "<C-o>db")

vim.keymap.set('n', '<leader>xd', function()
  vim.diagnostic.setloclist()
end)

vim.keymap.set('n', '<leader>e', function()
  vim.diagnostic.open_float()
end, { desc = 'Show diagnostics in a floating window' })

vim.keymap.set("n", "<leader>rs", function() vim.cmd("LspRestart roslyn") end, { buffer = bufnr, desc = "Restart Roslyn LSP Server" })

-- Devdocs
vim.keymap.set("n", "<leader>io", "<cmd>DevdocsOpenFloat<cr>", { desc = "Open Devdocs" })

