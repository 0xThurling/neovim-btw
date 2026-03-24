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

vim.keymap.set('n', '<S-C-v>', '<C-v>', { desc = 'Visual Block Mode (requires terminal paste shortcut disabled)' })
vim.keymap.set('n', '<C-v>', '<C-v>', { desc = 'Visual Block Mode' })
vim.keymap.set('n', '<A-v>', '<C-v>', { desc = 'Visual Block Mode' })

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

vim.keymap.set("n", "<C-l>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlighting" })
vim.keymap.set("n", "<esc><esc>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlighting" })

-- Open dadbod
vim.keymap.set("n", "<leader>d", ":DBUI<CR>", { desc = "Open Dadbod" })

vim.keymap.set('t', '<C-q>', "<C-\\><C-n>", { desc = 'Exit Terminal Mode' })
vim.keymap.set('t', '<C-\\><C-n>', "<C-\\><C-n>", { desc = 'Exit Terminal Mode' })

vim.keymap.set("i", "<M-Backspace>", "<C-o>db")

vim.keymap.set('n', '<leader>xd', function()
  vim.diagnostic.setloclist()
end)

vim.keymap.set('n', '<leader>e', function()
  vim.diagnostic.open_float()
end, { desc = 'Show diagnostics in a floating window' })

vim.keymap.set("n", "<leader>rs", function() vim.cmd("LspRestart roslyn") end, { desc = "Restart Roslyn LSP Server" })

-- Lazygit
vim.keymap.set("n", "<leader>gg", function()
	vim.cmd("botright terminal lazygit")
end, { desc = "Open Lazygit" })

vim.keymap.set("n", "<leader>gf", function()
	vim.cmd("botright terminal lazygit filter")
end, { desc = "Lazygit Filter" })

vim.keymap.set("n", "<leader>gF", function()
	vim.cmd("botright terminal lazygit filter --current-file")
end, { desc = "Lazygit Filter Current File" })

-- Terminal in floating window
local function open_terminal_float(cmd)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.95),
		height = math.floor(vim.o.lines * 0.95),
		col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.95)) / 2),
		row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.95)) / 2),
		border = "rounded",
	})
	vim.api.nvim_set_current_buf(buf)
	vim.fn.termopen(cmd)
	vim.cmd("startinsert")
end

-- API docs with glow - telescope picker + terminal float for colors
local function open_glow_doc()
	local data_dir = vim.fn.stdpath("data") .. "/apidocs-data/"
	
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local conf = require("telescope.config").values
	
	local doc_names = vim.fn.globpath(data_dir, "*", 0, 1)
	if #doc_names == 0 then
		vim.notify("No API docs installed", vim.log.levels.WARN)
		return
	end
	
	local files = {}
	for _, d in ipairs(doc_names) do
		local doc = vim.fn.fnamemodify(d, ":t")
		if doc ~= "elinks.conf" then
			local doc_files = vim.fn.globpath(d, "*", 0, 1)
			for _, f in ipairs(doc_files) do
				local fname = vim.fn.fnamemodify(f, ":t")
				table.insert(files, { path = f, doc = doc, name = fname })
			end
		end
	end
	
	table.sort(files, function(a, b) return a.name < b.name end)
	
	pickers.new({}, {
		prompt_title = "API Docs",
		finder = finders.new_table({
			results = files,
			entry_maker = function(entry)
				local display_name = entry.name:match("^[^#]+") or entry.name
				return {
					value = entry,
					display = display_name .. " [" .. entry.doc .. "]",
					ordinal = display_name
				}
			end
		}),
		sorter = conf.file_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = require("telescope.actions.state").get_selected_entry()
				actions.close(prompt_bufnr)
				
				open_terminal_float("glow -w 0 " .. vim.fn.shellescape(selection.value.path))
			end)
			return true
		end
	}):find()
end

local _slugs_to_mtimes = {}

local function fetch_slugs_and_then(callback)
	vim.system({"curl", "-L", "https://devdocs.io/docs.json"}, {text=true}, vim.schedule_wrap(function(res)
		local data = vim.fn.json_decode(res.stdout)
		_slugs_to_mtimes = {}
		for _, doc in ipairs(data) do
			_slugs_to_mtimes[doc.slug] = doc.mtime
		end
		callback()
	end))
end

local function install_with_telescope()
	fetch_slugs_and_then(function()
		local docs = {}
		for slug, _ in pairs(_slugs_to_mtimes) do
			table.insert(docs, slug)
		end
		table.sort(docs)
		
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local actions = require("telescope.actions")
		local conf = require("telescope.config").values
		
		pickers.new({}, {
			prompt_title = "Install API Docs",
			finder = finders.new_table({
				results = docs,
				entry_maker = function(entry)
					return { value = entry, display = entry, ordinal = entry }
				end
			}),
			sorter = conf.file_sorter(),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = require("telescope.actions.state").get_selected_entry()
					actions.close(prompt_bufnr)
					require("apidocs.install").apidoc_install(selection.value, _slugs_to_mtimes)
				end)
				return true
			end
		}):find()
	end)
end

vim.keymap.set("n", "<leader>ig", open_glow_doc, { desc = "Open API doc with glow" })
vim.keymap.set("n", "<leader>ii", install_with_telescope, { desc = "Install API docs" })
vim.keymap.set("n", "<leader>is", "<cmd>ApidocsSearch<cr>", { desc = "Search API docs" })



-- Code actions (fallback if no LSP attached)
vim.keymap.set("n", "<leader>ca", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end
  vim.lsp.buf.code_action()
end, { desc = "Code Actions" })

