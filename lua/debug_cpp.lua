local M = {}

-- Resolve paths for codelldb adapter provided by mason
local function get_codelldb_paths()
  local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
  return codelldb_path, liblldb_path
end

-- Helper to find executable files in the workspace (used by launch configurations)
local function get_executables()
  local cwd = vim.fn.getcwd()
  local cmd = "find " .. vim.fn.shellescape(cwd) .. " -maxdepth 4 -type f -executable -not -path '*/.*' -not -path '*/build/CMakeFiles/*'"
  local list = vim.fn.systemlist(cmd)
  local executables = {}
  for _, path in ipairs(list) do
    if not path:match("%.sh$") and not path:match("%.py$") and not path:match("%.lua$") then
      table.insert(executables, path)
    end
  end
  return executables
end

-- Main setup function. Expects the global `dap` module to be passed in.
function M.setup(dap)
  local codelldb_path, liblldb_path = get_codelldb_paths()

  -- Register codelldb adapter
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = codelldb_path,
      args = { "--port", "${port}" },
    },
  }

  -- Helper to retrieve compiler flags for the current buffer
  local function get_flags()
    local keymaps_ok, keymaps = pcall(require, "core.keymaps")
    if keymaps_ok and keymaps.get_flags_from_compile_commands then
      local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
      return keymaps.get_flags_from_compile_commands(file) or ""
    end
    local godbolt_ok, godbolt = pcall(require, "core.godbolt_local")
    if godbolt_ok and godbolt.resolve_compile_info then
      local info = godbolt.resolve_compile_info(vim.api.nvim_buf_get_name(0))
      if info and info.flags then
        return table.concat(info.flags, " ")
      end
    end
    return "-std=c++20"
  end

  local cpp_config = {
    {
      name = "Compile & Debug Current File",
      type = "codelldb",
      request = "launch",
      program = function()
        local ft = vim.bo.filetype
        local is_c = ft == "c"
        local compiler = is_c and "gcc" or "g++"
        local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
        local flags = get_flags()
        if not flags:find("-g") then
          flags = flags .. " -g"
        end
        local output_bin = "/tmp/godotbin"
        local cmd = string.format("%s %s %s -o %s", compiler, vim.fn.shellescape(file), flags, output_bin)
        vim.notify("Compiling for debugging...", vim.log.levels.INFO)
        local co = coroutine.running()
        if co then
          vim.system({ "sh", "-c", cmd }, {}, function(res)
            if res.code == 0 then
              vim.schedule(function()
                vim.notify("Compilation succeeded. Launching debugger...", vim.log.levels.INFO)
                coroutine.resume(co, output_bin)
              end)
            else
              vim.schedule(function()
                vim.notify("Compilation failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
                coroutine.resume(co, vim.NIL)
              end)
            end
          end)
          local result = coroutine.yield()
          if result == vim.NIL then return nil end
          return result
        end
        return output_bin
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = function()
        local input = vim.fn.input("Program arguments (space-separated): ")
        return vim.split(input, " ", { trimempty = true })
      end,
    },
    {
      name = "Launch Executable",
      type = "codelldb",
      request = "launch",
      program = function()
        local execs = get_executables()
        if #execs == 1 then
          return execs[1]
        elseif #execs > 1 then
          local co = coroutine.running()
          if co then
            vim.schedule(function()
              vim.ui.select(execs, {
                prompt = "Select executable to debug:",
                format_item = function(item) return vim.fn.fnamemodify(item, ":.") end,
              }, function(choice) coroutine.resume(co, choice or vim.NIL) end)
            end)
            local choice = coroutine.yield()
            if choice == vim.NIL then return nil end
            return choice
          end
        end
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = function()
        local input = vim.fn.input("Program arguments (space-separated): ")
        return vim.split(input, " ", { trimempty = true })
      end,
    },
    {
      name = "Attach to Process",
      type = "codelldb",
      request = "attach",
      pid = require("dap.utils").get_pid,
      cwd = "${workspaceFolder}",
    },
  }

  dap.configurations.cpp = cpp_config
  dap.configurations.c = cpp_config

  -- <leader>pd: view disassembly of the last compiled debug binary
  local keymap_opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>qd", function()
    local bin = "/tmp/godotbin"
    if vim.fn.filereadable(bin) == 0 then
      vim.notify("No debug binary found. Run <leader>pc first.", vim.log.levels.WARN)
      return
    end
    local out = vim.fn.systemlist("objdump -d --no-show-raw-insn --demangle " .. bin)
    vim.cmd("tabnew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
    vim.bo.filetype = "asm"
    vim.bo.modifiable = false
    vim.notify("Disassembly loaded (read-only)", vim.log.levels.INFO)
  end, vim.tbl_extend("force", keymap_opts, { desc = "C++: View disassembly of last compiled binary" }))
end

return M
