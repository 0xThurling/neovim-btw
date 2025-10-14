
return {
  {
    "mason-org/mason.nvim",
    branch = "v1.x",
    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry", -- Add custom registry
        },
        ensure_installed = {
          "csharpier", -- for formatting
        },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    branch = "v1.x"
  },
}
