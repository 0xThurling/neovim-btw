return {
  "stevearc/oil.nvim",
  opts = {
    view_options = {
      show_hidden = true,
    },
    win_options = {
      winblend = 10,
      winhighlight = "Normal:Normal,NormalNC:NormalNC",
    },
    floating_preview_options = {
      border = "rounded",
    },
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function(_, opts)
    require("oil").setup(opts)
    vim.keymap.set("n", "<Tab>e", function()
      require("oil").toggle_float()
    end, { desc = "Open parent directory" })
  end,
}
