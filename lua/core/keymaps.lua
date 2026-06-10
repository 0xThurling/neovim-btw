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

local function open_floating_asm(asm_file)
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		border = "rounded",
	})
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_name(buf, asm_file)
	local f = io.open(asm_file, "r")
	if f then
		local content = f:read("*all")
		f:close()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { plain = true, trimquotes = false }))
	end
	vim.bo.buftype = ""
	vim.bo.buflisted = false
	vim.bo.bufhidden = "wipe"
	vim.bo.filetype = "asm"
end

local function find_compile_commands()
	local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	while dir ~= "/" do
		local path = vim.fs.joinpath(dir, "compile_commands.json")
		if vim.fn.filereadable(path) == 1 then
			return path, vim.fs.dirname(path)
		end
		dir = vim.fs.dirname(dir)
	end
	return nil, nil
end

local function get_flags_from_compile_commands(file_path)
 	local compile_commands_path, _ = find_compile_commands()
 	if not compile_commands_path then
 		return nil
 	end
 	local f = io.open(compile_commands_path, "r")
 	if not f then
 		return nil
 	end
 	local content = f:read("*all")
 	f:close()
 	local ok, compile_commands = pcall(vim.fn.json_decode, content)
 	if not ok then
 		return nil
 	end
 	for _, entry in ipairs(compile_commands) do
 		if entry.file and vim.fn.fnamemodify(entry.file, ":p") == file_path then
 			local command = entry.command
 			local escaped_file = vim.fn.shellescape(file_path)
 			command = command:gsub("^(%S+%s+)", "")
 			command = command:gsub(escaped_file, "")
 			command = command:gsub("%s%-o%s+%S+", "")
 			command = command:gsub("%s+", " "):match("^%s*(.*)"):match("(%S.*)") or ""
 			return command
 		end
 	end
 	return nil
 end

local function compile_cpp()
 	local ft = vim.bo.filetype
 	local is_c = ft == "c"
 	local compiler = is_c and "gcc" or "g++"
 	local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
 	local file_flags = get_flags_from_compile_commands(file)
 	if not file_flags then
 		file_flags = ""
 	end
 	local cmd = string.format("%s %s %s -o /tmp/godotbin", compiler, vim.fn.shellescape(file), file_flags)
 	vim.notify("Compiling...", vim.log.levels.INFO)
 	open_terminal_float(cmd)
 end

local function compile_asm_cpp()
 	local ft = vim.bo.filetype
 	local is_c = ft == "c"
 	local compiler = is_c and "gcc" or "g++"
 	local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
 	local file_flags = get_flags_from_compile_commands(file)
 	if not file_flags then
 		file_flags = "-O2"
 	end
 	local asm_file = "/tmp/godotasm.s"
 	local cmd = string.format("%s %s %s -S -o %s", compiler, vim.fn.shellescape(file), file_flags, asm_file)
 	vim.notify("Compiling to assembly...", vim.log.levels.INFO)
 	vim.system({ "sh", "-c", cmd }, {}, vim.schedule_wrap(function(result)
 		if result.code == 0 then
 			open_floating_asm(asm_file)
 		else
 			vim.notify("Assembly compilation failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
 		end
 	end))
 end

local function compile_run_cpp()
 	local ft = vim.bo.filetype
 	local is_c = ft == "c"
 	local compiler = is_c and "gcc" or "g++"
 	local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
 	local file_flags = get_flags_from_compile_commands(file)
 	if not file_flags then
 		file_flags = ""
 	end
 	local cmd = string.format("%s %s %s -o /tmp/godotbin && /tmp/godotbin", compiler, vim.fn.shellescape(file), file_flags)
 	vim.notify("Compiling & running...", vim.log.levels.INFO)
 	open_terminal_float(cmd)
 end

vim.api.nvim_create_user_command("Godbolt", function(opts)
	require("core.godbolt_local").run_local_godbolt(opts)
end, { range = true, desc = "Generate assembly locally with Godbolt-like filtering" })

vim.keymap.set("n", "<leader>cc", compile_cpp, { noremap = true, silent = true, desc = "Compile C/C++ locally" })
vim.keymap.set({ "n", "v" }, "<leader>cA", ":Godbolt<CR>", { noremap = true, silent = true, desc = "Compile C/C++ to assembly (Local Godbolt)" })
vim.keymap.set({ "n", "v" }, "<leader>gb", ":Godbolt<CR>", { noremap = true, silent = true, desc = "Run local Godbolt" })
vim.keymap.set("n", "<leader>cr", compile_run_cpp, { noremap = true, silent = true, desc = "Compile & run C/C++ locally" })


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

local function show_doc_picker(matches, word)
	if #matches == 0 then
		vim.notify("No docs found for: " .. word, vim.log.levels.WARN)
		return
	end
	
	table.sort(matches)
	
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local conf = require("telescope.config").values
	
	pickers.new({}, {
		prompt_title = "Docs for: " .. word,
		finder = finders.new_table({
			results = matches,
			entry_maker = function(entry)
				local display = vim.fn.fnamemodify(entry, ":t"):match("^[^#]+") or vim.fn.fnamemodify(entry, ":t")
				return { value = entry, display = display, ordinal = display }
			end
		}),
		sorter = conf.file_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = require("telescope.actions.state").get_selected_entry()
				actions.close(prompt_bufnr)
				open_terminal_float("glow -w 0 " .. vim.fn.shellescape(selection.value))
			end)
			return true
		end
	}):find()
end

-- Show API docs for word under cursor (search filename only in apidocs)
vim.keymap.set("n", "<leader>ig", function()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end
	
	local data_dir = vim.fn.stdpath("data") .. "/apidocs-data/"
	
	local handle = io.popen("find " .. data_dir .. " -type f \\( -name '*" .. word .. "*.md' -o -name '*" .. word .. "*.html.md' \\) 2>/dev/null")
	if not handle then
		vim.notify("Search failed", vim.log.levels.ERROR)
		return
	end
	
	local file_matches = {}
	for line in handle:lines() do
		if line ~= "" then
			table.insert(file_matches, line)
		end
	end
	handle:close()
	
	if #file_matches == 0 then
		vim.notify("No docs found for: " .. word, vim.log.levels.WARN)
		return
	end
	
	show_doc_picker(file_matches, word)
end, { desc = "Show API docs for word under cursor" })
vim.keymap.set("n", "<leader>ii", install_with_telescope, { desc = "Install API docs" })

-- Glow for any markdown file with telescope
vim.keymap.set("n", "<leader>om", function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local conf = require("telescope.config").values
	
	local files = {}
	local handle = io.popen("find . -type f -name '*.md' -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null")
	if handle then
		for line in handle:lines() do
			table.insert(files, line)
		end
		handle:close()
	end
	table.sort(files)
	
	if #files == 0 then
		vim.notify("No markdown files found", vim.log.levels.WARN)
		return
	end
	
	pickers.new({}, {
		prompt_title = "Find Markdown Files",
		finder = finders.new_table({
			results = files,
			entry_maker = function(entry)
				return { value = entry, display = entry, ordinal = entry }
			end
		}),
		sorter = conf.file_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = require("telescope.actions.state").get_selected_entry()
				actions.close(prompt_bufnr)
				
				local out = vim.fn.system("glow -w 0 " .. vim.fn.shellescape(selection.value))
				if vim.v.shell_error ~= 0 then
					vim.notify("Glow error: " .. out, vim.log.levels.ERROR)
					return
				end
				
				vim.cmd("vsplit")
				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_set_current_buf(buf)
				vim.fn.termopen("glow -w 0 " .. vim.fn.shellescape(selection.value))
				vim.cmd("startinsert")
			end)
			return true
		end,
	}):find()
end, { desc = "Open markdown with glow" })

-- Browse all API docs
vim.keymap.set("n", "<leader>iG", function()
	open_glow_doc()
end, { desc = "Browse API docs" })

vim.keymap.set("n", "<leader>is", "<cmd>ApidocsSearch<cr>", { desc = "Search API docs" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })



-- Code actions (fallback if no LSP attached)
vim.keymap.set("n", "<leader>ca", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end
  vim.lsp.buf.code_action()
end, { desc = "Code Actions" })

