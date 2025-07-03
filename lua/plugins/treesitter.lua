return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "svelte", "http", "typescript" },
        highlight = { enable = true },
      }
    end,
  },
}
