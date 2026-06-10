local M = {}

-- Helper: Split a shell command string into individual arguments, handling quotes
local function split_command(cmd_str)
  local args = {}
  local in_quotes = false
  local quote_char = nil
  local current = ""
  local i = 1
  while i <= #cmd_str do
    local char = cmd_str:sub(i, i)
    if (char == '"' or char == "'") then
      if in_quotes then
        if char == quote_char then
          in_quotes = false
          quote_char = nil
        else
          current = current .. char
        end
      else
        in_quotes = true
        quote_char = char
      end
    elseif char == " " and not in_quotes then
      if current ~= "" then
        table.insert(args, current)
        current = ""
      end
    else
      current = current .. char
    end
    i = i + 1
  end
  if current ~= "" then
    table.insert(args, current)
  end
  return args
end

-- Helper: Canonicalize file paths
local function canonicalize(path, base_dir)
  if not path:find("^/") and base_dir then
    path = base_dir .. "/" .. path
  end
  -- Replace multiple slashes and dot segments
  path = path:gsub("//+", "/")
  return vim.fn.fnamemodify(path, ":p")
end

-- Find compile_commands.json by walking up the directory tree
function M.find_compile_commands(file_path)
  local dir = vim.fs.dirname(file_path)
  while dir and dir ~= "/" and dir ~= "" do
    local path = vim.fs.joinpath(dir, "compile_commands.json")
    if vim.fn.filereadable(path) == 1 then
      return path, dir
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then break end
    dir = parent
  end
  return nil, nil
end

-- Parse compile_commands.json and extract compiler, directory, and flags for a file
function M.resolve_compile_info(file_path)
  local abs_file_path = vim.fn.fnamemodify(file_path, ":p")
  local compile_commands_path, project_root = M.find_compile_commands(abs_file_path)
  
  local file_ext = vim.fn.fnamemodify(abs_file_path, ":e"):lower()
  local is_c = (file_ext == "c" or file_ext == "h")
  local default_compiler = is_c and "gcc" or "g++"
  local default_flags = is_c and { "-O2" } or { "-O2", "-std=c++20" }
  local default_dir = vim.fs.dirname(abs_file_path)

  local default_info = {
    compiler = default_compiler,
    flags = default_flags,
    directory = default_dir
  }

  if not compile_commands_path then
    return default_info
  end

  local f = io.open(compile_commands_path, "r")
  if not f then
    return default_info
  end
  local content = f:read("*all")
  f:close()

  local ok, compile_commands = pcall(vim.json.decode, content)
  if not ok then
    ok, compile_commands = pcall(vim.fn.json_decode, content)
  end
  if not ok or type(compile_commands) ~= "table" then
    return default_info
  end

  -- Helper to extract compile arguments from entry
  local function extract_entry_info(entry)
    local compiler = nil
    local raw_flags = {}
    local dir = entry.directory or project_root

    if entry.arguments and type(entry.arguments) == "table" and #entry.arguments > 0 then
      compiler = entry.arguments[1]
      for j = 2, #entry.arguments do
        table.insert(raw_flags, entry.arguments[j])
      end
    elseif entry.command and type(entry.command) == "string" then
      local parts = split_command(entry.command)
      if #parts > 0 then
        compiler = parts[1]
        for j = 2, #parts do
          table.insert(raw_flags, parts[j])
        end
      end
    end

    if not compiler then
      return nil
    end

    -- Filter out input files, output flags, and compilation flags that interfere with ASM generation
    local flags = {}
    local skip_next = false
    for _, arg in ipairs(raw_flags) do
      if skip_next then
        skip_next = false
      elseif arg == "-o" then
        skip_next = true
      elseif arg == "-c" then
        -- Skip compilation-only flag since we will append -S
      elseif not arg:find("%.cpp$") and not arg:find("%.c$") and not arg:find("%.cc$") and not arg:find("%.cxx$") and not arg:find("%.C$") then
        table.insert(flags, arg)
      end
    end

    return {
      compiler = compiler,
      flags = flags,
      directory = dir
    }
  end

  -- 1. Look for exact match
  for _, entry in ipairs(compile_commands) do
    if entry.file then
      local entry_file_abs = canonicalize(entry.file, entry.directory or project_root)
      if entry_file_abs == abs_file_path then
        local info = extract_entry_info(entry)
        if info then return info end
      end
    end
  end

  -- 2. If it's a header or no exact match, look for a source file in the same directory
  local file_dir = vim.fs.dirname(abs_file_path)
  local file_base = vim.fn.fnamemodify(abs_file_path, ":t:r")
  
  -- Sibling with same name first (e.g. foo.cpp for foo.hpp)
  for _, entry in ipairs(compile_commands) do
    if entry.file then
      local entry_file_abs = canonicalize(entry.file, entry.directory or project_root)
      local entry_dir = vim.fs.dirname(entry_file_abs)
      local entry_base = vim.fn.fnamemodify(entry_file_abs, ":t:r")
      if entry_dir == file_dir and entry_base == file_base then
        local info = extract_entry_info(entry)
        if info then return info end
      end
    end
  end

  -- Sibling in same directory
  for _, entry in ipairs(compile_commands) do
    if entry.file then
      local entry_file_abs = canonicalize(entry.file, entry.directory or project_root)
      local entry_dir = vim.fs.dirname(entry_file_abs)
      if entry_dir == file_dir then
        local info = extract_entry_info(entry)
        if info then return info end
      end
    end
  end

  -- 3. Fallback to the first compile command in the file
  if #compile_commands > 0 then
    local info = extract_entry_info(compile_commands[1])
    if info then return info end
  end

  return default_info
end

-- Filter assembly output: strip comments, directives, unused labels, and focus on visual range
function M.filter_assembly(asm_path, source_path, start_line, end_line, base_dir)
  local f = io.open(asm_path, "r")
  if not f then
    return nil, "Failed to open assembly file"
  end
  local lines = {}
  for line in f:lines() do
    table.insert(lines, line)
  end
  f:close()

  -- Canonicalize source path
  local canonical_source = canonicalize(source_path, base_dir)

  -- Parse .file directives to identify the source file index
  local source_file_idx = nil
  for _, line in ipairs(lines) do
    local idx, dir, file = line:match('^%s*%.file%s+(%d+)%s+"([^"]+)"%s+"([^"]+)"')
    if idx then
      local full_path = canonicalize(dir .. "/" .. file, base_dir)
      if full_path == canonical_source then
        source_file_idx = tonumber(idx)
        break
      end
    else
      local idx2, file2 = line:match('^%s*%.file%s+(%d+)%s+"([^"]+)"')
      if idx2 then
        local full_path = canonicalize(file2, base_dir)
        if full_path == canonical_source then
          source_file_idx = tonumber(idx2)
          break
        end
      end
    end
  end

  -- Read source lines to print as comments
  local source_lines = {}
  local src_f = io.open(source_path, "r")
  if src_f then
    for line in src_f:lines() do
      table.insert(source_lines, line)
    end
    src_f:close()
  end

  local output = {}
  local skip_section = false
  local current_file_idx = nil
  local current_line = nil
  local last_source_line = nil
  local current_function_in_range = (source_file_idx == nil) -- If no debug info, keep all functions
  local has_set_func_range = false
  local buffered_labels = {}
  
  -- Set of labels referenced by instructions
  local referenced_labels = {}
  local pass1_lines = {}
  
  for _, line in ipairs(lines) do
    local raw_line = line
    -- Strip comments on the line for analysis
    local line_no_comment = line:gsub("%s*[#;].*$", "")
    
    -- Check for section starts
    local sec_name = line_no_comment:match('^%s*%.section%s+([%w%.%-_]+)')
    if sec_name then
      if sec_name:find("^%.debug") or sec_name:find("^%.note") or sec_name:find("^%.comment") or sec_name:find("^%.eh_frame") or sec_name:find("^%.gnu%.version") or sec_name:find("^%.meta") then
        skip_section = true
      else
        skip_section = false
      end
    elseif line_no_comment:match('^%s*%.text') or line_no_comment:match('^%s*%.data') or line_no_comment:match('^%s*%.bss') or line_no_comment:match('^%s*%.rodata') then
      skip_section = false
    end

    if not skip_section then
      -- Track .loc directives
      local file_idx, line_num = line_no_comment:match('^%s*%.loc%s+(%d+)%s+(%d+)')
      if file_idx and line_num then
        current_file_idx = tonumber(file_idx)
        current_line = tonumber(line_num)
        
        if source_file_idx then
          if current_file_idx == source_file_idx then
            last_source_line = current_line
            if not has_set_func_range then
              current_function_in_range = true
              has_set_func_range = true
            end
          else
            if not has_set_func_range then
              current_function_in_range = false
              has_set_func_range = true
            end
          end
        end
      end

      -- Check if it's a function label (ends with colon and does not start with local .L label prefix)
      local label = line_no_comment:match('^%s*([_%w%.]+):%s*$')
      if label then
        if not label:find("^%.L") then
          -- It's a function label definition! Reset function-level trackers.
          current_function_in_range = (source_file_idx == nil)
          has_set_func_range = false
          last_source_line = nil
        end
        table.insert(buffered_labels, { label = label, raw = raw_line })
      else
        -- Check if it's a blocklisted directive
        local is_directive = line_no_comment:match('^%s*%.%w+')
        local is_empty = line_no_comment:match('^%s*$')
        
        if not is_directive and not is_empty then
          -- It's an instruction!
          local in_range = false
          if current_function_in_range then
            if start_line and end_line then
              in_range = (last_source_line and last_source_line >= start_line and last_source_line <= end_line)
            else
              in_range = true
            end
          end
          
          if in_range then
            -- Flush buffered labels
            for _, lbl in ipairs(buffered_labels) do
              table.insert(pass1_lines, { type = "label", name = lbl.label, text = lbl.raw, file = current_file_idx, line = last_source_line })
            end
            buffered_labels = {}
            
            table.insert(pass1_lines, { type = "instruction", text = raw_line, file = current_file_idx, line = last_source_line })
            
            -- Find label references in this instruction
            for ref in line_no_comment:gmatch('%.L[%w_]+') do
              referenced_labels[ref] = true
            end
            for ref in line_no_comment:gmatch('[%w_]+') do
              referenced_labels[ref] = true
            end
          else
            buffered_labels = {}
          end
        elseif is_directive then
          local dir_type = line_no_comment:match('^%s*%.(%w+)')
          local keep_directives = { string = true, ascii = true, byte = true, value = true, short = true, long = true, quad = true, zero = true }
          if keep_directives[dir_type] then
            local in_range = false
            if current_function_in_range then
              if start_line and end_line then
                in_range = (last_source_line and last_source_line >= start_line and last_source_line <= end_line)
              else
                in_range = true
              end
            end
            if in_range then
              for _, lbl in ipairs(buffered_labels) do
                table.insert(pass1_lines, { type = "label", name = lbl.label, text = lbl.raw, file = current_file_idx, line = last_source_line })
              end
              buffered_labels = {}
              table.insert(pass1_lines, { type = "directive", text = raw_line, file = current_file_idx, line = last_source_line })
            end
          end
        end
      end
    end
  end

  -- Second pass: filter unused local labels and format the final output
  local last_source_line_out = nil
  for _, item in ipairs(pass1_lines) do
    if item.type == "label" then
      if not item.name:find("^%.L") or referenced_labels[item.name] then
        table.insert(output, item.text)
      end
    elseif item.type == "instruction" or item.type == "directive" then
      if item.line and item.line ~= last_source_line_out then
        local src_line = source_lines[item.line]
        if src_line then
          local clean_src = src_line:gsub("^%s+", "")
          if clean_src ~= "" then
            table.insert(output, string.format("  ;; %d: %s", item.line, clean_src))
          end
        end
        last_source_line_out = item.line
      end
      table.insert(output, item.text)
    end
  end

  return table.concat(output, "\n")
end

-- Open the generated assembly in a side-by-side split window
function M.show_assembly(source_path, asm_content)
  local source_buf = vim.api.nvim_get_current_buf()
  local source_filename = vim.fn.fnamemodify(source_path, ":t")
  local asm_buf_name = "godbolt://" .. source_filename .. ".s"

  -- Look for an existing buffer with the same name
  local asm_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):find(asm_buf_name, 1, true) then
      asm_buf = buf
      break
    end
  end

  if not asm_buf then
    -- Create a new buffer
    asm_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(asm_buf, asm_buf_name)
  end

  -- Set lines of the assembly buffer
  vim.bo[asm_buf].modifiable = true
  local lines = vim.split(asm_content, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(asm_buf, 0, -1, false, lines)
  
  -- Set options
  vim.bo[asm_buf].filetype = "asm"
  vim.bo[asm_buf].buftype = "nofile"
  vim.bo[asm_buf].bufhidden = "wipe"
  vim.bo[asm_buf].swapfile = false
  vim.bo[asm_buf].modifiable = false
  vim.bo[asm_buf].readonly = true

  -- Check if buffer is already displayed in a window
  local asm_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == asm_buf then
      asm_win = win
      break
    end
  end

  if not asm_win then
    -- Open a vertical split on the right
    vim.cmd("vsplit")
    asm_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(asm_win, asm_buf)
  else
    -- Focus the window
    vim.api.nvim_set_current_win(asm_win)
  end

  -- Move cursor back to source window
  local source_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == source_buf then
      source_win = win
      break
    end
  end
  if source_win then
    vim.api.nvim_set_current_win(source_win)
  end
end

-- Main compilation and display runner
function M.run_local_godbolt(opts)
  local source_path = vim.api.nvim_buf_get_name(0)
  if source_path == "" then
    vim.notify("Buffer has no file path", vim.log.levels.ERROR)
    return
  end

  local file_ext = vim.fn.fnamemodify(source_path, ":e"):lower()
  local is_header = (file_ext == "hpp" or file_ext == "h")
  
  -- Resolve compiler and flags
  local info = M.resolve_compile_info(source_path)
  
  local compile_file = source_path
  local temp_cpp_path = nil
  
  if is_header then
    -- If it's a header, compile a temporary cpp file that includes it
    temp_cpp_path = "/tmp/godbolt_temp_header." .. (file_ext == "h" and "c" or "cpp")
    local f = io.open(temp_cpp_path, "w")
    if f then
      f:write(string.format('#include "%s"\n', source_path))
      f:close()
      compile_file = temp_cpp_path
    else
      vim.notify("Failed to create temporary file for header compilation", vim.log.levels.ERROR)
      return
    end
  end

  -- Construct final compile command
  local cmd = { info.compiler }
  for _, flag in ipairs(info.flags) do
    table.insert(cmd, flag)
  end
  
  -- Append flags to generate clean assembly with debug info
  table.insert(cmd, "-S")
  table.insert(cmd, "-g")

  -- If using a GCC/G++ compiler, add -fkeep-inline-functions so that
  -- inline functions defined in headers are emitted to assembly
  local compiler_lower = info.compiler:lower()
  if (compiler_lower:find("g++") or compiler_lower:find("gcc") or compiler_lower:find("c++") or compiler_lower:find("cc")) and not compiler_lower:find("clang") then
    table.insert(cmd, "-fkeep-inline-functions")
  end

  table.insert(cmd, compile_file)
  table.insert(cmd, "-o")
  table.insert(cmd, "/tmp/godbolt_temp.s")

  -- Visual selection range
  local start_line = nil
  local end_line = nil
  if opts.range and opts.range > 0 then
    start_line = opts.line1
    end_line = opts.line2
  end

  vim.notify("Compiling assembly locally...", vim.log.levels.INFO)

  -- Run compiler asynchronously
  vim.system(cmd, { cwd = info.directory }, vim.schedule_wrap(function(obj)
    -- Clean up temporary header file if it was created
    if temp_cpp_path then
      os.remove(temp_cpp_path)
    end

    if obj.code == 0 then
      local filtered_asm, err = M.filter_assembly("/tmp/godbolt_temp.s", source_path, start_line, end_line, info.directory)
      if filtered_asm then
        if filtered_asm == "" then
          vim.notify("Assembly compilation succeeded, but no code generated for the selected range.", vim.log.levels.WARN)
        else
          M.show_assembly(source_path, filtered_asm)
        end
      else
        vim.notify("Failed to filter assembly: " .. tostring(err), vim.log.levels.ERROR)
      end
    else
      local stderr = obj.stderr or ""
      vim.notify("Compilation failed:\n" .. stderr, vim.log.levels.ERROR)
    end
  end))
end

return M
