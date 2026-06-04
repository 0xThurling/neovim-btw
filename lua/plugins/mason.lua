
return {
  {
    "mason-org/mason.nvim",
    branch = "v1.x",
    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
        ensure_installed = {
          "csharpier", -- for formatting
        },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    branch = "v1.x",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "csharpier", -- for formatting
          "roslyn-nightly",
        },
      })
    end,
  },
}
