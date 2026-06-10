-- aerial.nvim: symbol outline sidebar (functions, classes, structs, enums)
-- Particularly useful for navigating large C++ headers and source files
return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
        layout = {
          max_width = { 40, 0.2 },
          min_width = 25,
          default_direction = "right",
          placement = "edge",
        },
        attach_mode = "global",
        -- Show box-drawing lines for the tree structure
        show_guides = true,
        guides = {
          mid_item   = "├─ ",
          last_item  = "└─ ",
          nested_top = "│  ",
          whitespace = "   ",
        },
        -- Filter to only show symbols relevant for low-level C++ work
        filter_kind = {
          "Class", "Constructor", "Enum", "EnumMember",
          "Function", "Interface", "Method", "Module",
          "Namespace", "Struct", "Type", "TypeParameter", "Variable",
        },
        highlight_on_hover = true,
        autojump = false,
        -- Open aerial when entering a C/C++/Rust file wider than 120 cols
        open_automatic = function(bufnr)
          local ft = vim.bo[bufnr].filetype
          return vim.tbl_contains({ "c", "cpp", "rust" }, ft)
            and vim.fn.winwidth(0) > 120
        end,
      })

      local keymap_opts = { noremap = true, silent = true }
      -- Toggle the outline panel
      vim.keymap.set("n", "<leader>ps", "<cmd>AerialToggle!<cr>",
        vim.tbl_extend("force", keymap_opts, { desc = "C++: Toggle symbol outline" }))
      -- Jump to previous/next symbol in the file
      vim.keymap.set("n", "[[", "<cmd>AerialPrev<cr>",
        vim.tbl_extend("force", keymap_opts, { desc = "Jump to previous symbol" }))
      vim.keymap.set("n", "]]", "<cmd>AerialNext<cr>",
        vim.tbl_extend("force", keymap_opts, { desc = "Jump to next symbol" }))
    end,
  },
}
