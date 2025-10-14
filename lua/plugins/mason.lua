
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
    branch = "v1.x",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "gopls",
          "html",
          "clangd",
          "pyright",
          "sqlls",
          "rust_analyzer",
          "asm_lsp",
          "angularls",
          "bashls",
          "svelte",
          "cssls",
          "herb_ls",
        },
        automatic_installation = true,
      })
    end,
  },
}
