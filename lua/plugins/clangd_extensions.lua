-- clangd_extensions: inlay hints, AST viewer, type hierarchy, memory layout
return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = true,
          only_current_line = false,
          only_current_line_autocmd = "CursorHold",
          show_parameter_hints = true,
          parameter_hints_prefix = "← ",
          other_hints_prefix = "» ",
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 7,
          highlight = "Comment",
        },
        ast = {
          -- ASCII icons — render correctly in any terminal
          role_icons = {
            type             = "",
            declaration      = "",
            expression       = "",
            specifier        = "",
            statement        = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound          = "",
            Recovery          = "",
            TranslationUnit   = "",
            PackExpansion     = "",
            TemplateTypeParm  = "",
            TemplateTemplateParm = "",
            TemplateParamObject  = "",
          },
        },
        memory_usage = { border = "rounded" },
        symbol_info  = { border = "rounded" },
      })

      local keymap_opts = { noremap = true, silent = true }

      vim.keymap.set("n", "<leader>qA", "<cmd>ClangdAST<cr>",
        vim.tbl_extend("force", keymap_opts, { desc = "C++: View AST node" }))

      -- Real struct/class memory layout using clang's -fdump-record-layouts
      vim.keymap.set("n", "<leader>qm", function()
        local file = vim.fn.expand("%:p")

        -- If cursor is on a keyword, grab the next word (the actual type name)
        local keywords = { struct = true, class = true, union = true, enum = true }
        local word = vim.fn.expand("<cword>")
        if keywords[word] then
          local line_text = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local rest = line_text:sub(col + 1)
          word = rest:match("%s+([%w_:]+)") or word
        end

        -- Clang only dumps layouts for types that are actually used.
        -- Create a temp wrapper that #includes the real file and touches the type.
        local tmp = "/tmp/_nvim_layout_probe.cpp"
        local probe = string.format(
          '#include "%s"\nvoid __nvim_probe() { volatile %s __x; (void)__x; }\n',
          file, word
        )
        local f = io.open(tmp, "w")
        if not f then
          vim.notify("Failed to create temp file", vim.log.levels.ERROR)
          return
        end
        f:write(probe)
        f:close()

        -- Try to get flags from compile_commands.json
        local flags = "-std=c++20"
        local keymaps_ok, keymaps = pcall(require, "core.keymaps")
        if keymaps_ok and keymaps.get_flags_from_compile_commands then
          local fl = keymaps.get_flags_from_compile_commands(file)
          if fl and fl ~= "" then flags = fl end
        end

        local cmd = string.format(
          "/usr/bin/clang++ -Xclang -fdump-record-layouts -fsyntax-only %s %s 2>&1",
          flags, vim.fn.shellescape(tmp)
        )

        local raw = vim.fn.systemlist(cmd)

        -- Collect layout blocks, keep those matching the type name
        local blocks, current = {}, nil
        for _, line in ipairs(raw) do
          if line:match("^%*%*%* Dumping AST Record Layout") then
            if current then table.insert(blocks, current) end
            current = { line }
          elseif current then
            table.insert(current, line)
          end
        end
        if current then table.insert(blocks, current) end

        local matched = {}
        for _, block in ipairs(blocks) do
          for _, l in ipairs(block) do
            if l:match(word) then
              vim.list_extend(matched, block)
              table.insert(matched, "")
              break
            end
          end
        end

        local lines = #matched > 0 and matched or raw
        if #matched == 0 then
          table.insert(lines, 1, ("-- No layout found for '%s'"):format(word))
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].filetype = "c"
        vim.bo[buf].modifiable = false

        local width  = math.min(90, vim.o.columns - 4)
        local height = math.min(math.max(#lines, 5), vim.o.lines - 6)
        vim.api.nvim_open_win(buf, true, {
          relative  = "editor",
          width     = width,
          height    = height,
          col       = math.floor((vim.o.columns - width) / 2),
          row       = math.floor((vim.o.lines - height) / 2),
          style     = "minimal",
          border    = "rounded",
          title     = " Record Layout: " .. word .. " ",
          title_pos = "center",
        })
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
      end, vim.tbl_extend("force", keymap_opts, { desc = "C++: Dump struct/class memory layout" }))

      vim.keymap.set("n", "<leader>qS", "<cmd>ClangdSymbolInfo<cr>",
        vim.tbl_extend("force", keymap_opts, { desc = "C++: Symbol info" }))

      vim.keymap.set("n", "<leader>qh", "<cmd>ClangdTypeHierarchy<cr>",
        vim.tbl_extend("force", keymap_opts, { desc = "C++: Type hierarchy" }))

      -- Toggle inlay hints on/off with <leader>qI
      vim.keymap.set("n", "<leader>qI", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
      end, vim.tbl_extend("force", keymap_opts, { desc = "C++: Toggle inlay hints" }))
    end,
  },
}
