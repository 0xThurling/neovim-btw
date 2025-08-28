return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "svelte", "http", "typescript", "c_sharp", "razor" },
        highlight = { enable = true },
      }
    end,
  },
}
