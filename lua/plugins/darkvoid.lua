-- lua/plugins/darkvoid.lua
return {
  "aliqyan-21/darkvoid.nvim", -- change to the actual repo if needed
  lazy = false,
  priority = 1000, -- Load colorscheme early
  config = function()
    require("darkvoid").setup({
      transparent = false,
      glow = false,
      show_end_of_buffer = true,
      colors = {
        fg = "#c0c0c0",
        bg = "#1c1c1c",
        cursor = "#bdfe58",
        line_nr = "#404040",
        visual = "#303030",
        comment = "#585858",
        string = "#d1d1d1",
        func = "#e1e1e1",
        kw = "#f1f1f1",
        identifier = "#b1b1b1",
        type = "#a1a1a1",
        type_builtin = "#c5c5c5",
        search_highlight = "#1bfd9c",
        operator = "#1bfd9c",
        bracket = "#e6e6e6",
        preprocessor = "#4b8902",
        bool = "#66b2b2",
        constant = "#b2d8d8",
        plugins = {
          gitsigns = true,
          nvim_cmp = true,
          treesitter = true,
          nvimtree = true,
          telescope = true,
          lualine = true,
          bufferline = true,
          oil = true,
          whichkey = true,
          nvim_notify = true,
        },
        added = "#baffc9",
        changed = "#ffffba",
        removed = "#ffb3ba",
        pmenu_bg = "#1c1c1c",
        pmenu_sel_bg = "#1bfd9c",
        pmenu_fg = "#c0c0c0",
        eob = "#3c3c3c",
        border = "#585858",
        title = "#bdfe58",
        bufferline_selection = "#1bfd9c",
        error = "#dea6a0",
        warning = "#d6efd8",
        hint = "#bedc74",
        info = "#7fa1c3",
      },
    })
    vim.cmd("colorscheme darkvoid")
  end,
}

