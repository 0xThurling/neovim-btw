-- Helper: find project root by looking for a marker (like .git)
local function find_root(marker)
  local cwd = vim.fn.getcwd()
  local path = cwd

  while path ~= "/" do
    if vim.fn.isdirectory(path .. "/" .. marker) == 1 then
      return path
    end
    path = vim.fn.fnamemodify(path, ":h")
  end

  return cwd
end

-- Use the helper instead of lspconfig.util.root_pattern
local path = find_root(".git")
local cpm_definitions_path = path .. "/.config/forge/definitions"

local library_paths = vim.api.nvim_get_runtime_file("", true)
table.insert(library_paths, cpm_definitions_path)

return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
			function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "rounded"
				if syntax == "" or syntax == nil then
					syntax = "markdown"
				end
				return orig_util_open_floating_preview(contents, syntax, opts, ...)
			end
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason").setup({
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry", -- Add custom registry
				},
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
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
					"taplo",
					"tailwindcss",
					"emmet_ls",
					"jsonls",
					"marksman",
					"lemminx", -- XML
				},
				automatic_installation = true,
        automatic_enable = false
			})
			local lsp_utils = require("core.lsp_utils")

      vim.lsp.config('lua_ls', {
				capabilities = capabilities,
				on_attach = lsp_utils.on_attach,
				settings = {
					Lua = {
						workspace = {
							library = library_paths
						},
					},
				},
      })

			vim.lsp.config('clangd', {
				capabilities = capabilities,
				on_attach = lsp_utils.on_attach,
			})

      vim.lsp.enable('lua_ls')
      vim.lsp.enable('clangd')

			-- lspconfig.html.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			--
			-- lspconfig.pyright.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.sqlls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.rust_analyzer.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.asm_lsp.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.angularls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.bashls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.svelte.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.cssls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.taplo.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.tailwindcss.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.emmet_ls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.jsonls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.marksman.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })
			--
			-- lspconfig.lemminx.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = lsp_utils.on_attach,
			-- })

			-- Setup the Error float window
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
		end,
	},
}
