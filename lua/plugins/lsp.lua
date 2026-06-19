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
    event = {"BufReadPre", "BufNewFile"},
		config = function()
			-- Configure hover float border without overriding syntax
			-- (forcing markdown syntax on all floats causes treesitter nil-node crashes)
			local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
			function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "rounded"
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
          "pyright",
          "ts_ls",
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
        cmd = {'/usr/bin/lua-language-server'},
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
				cmd = {
					"clangd",
					"--background-index",           -- index entire project in background
					"--clang-tidy",                 -- enable clang-tidy linting
					"--header-insertion=iwyu",      -- include-what-you-use style includes
					"--completion-style=detailed",  -- richer completions
					"--function-arg-placeholders",  -- fill in argument names in completions
					"--fallback-style=llvm",        -- LLVM style as default
				},
			})

			vim.lsp.config('pyright', {
				capabilities = capabilities,
				on_attach = lsp_utils.on_attach,
			})

			vim.lsp.config('ts_ls', {
				capabilities = capabilities,
				on_attach = lsp_utils.on_attach,
			})

      vim.lsp.config('emmet_ls', {
        capabilities = capabilities,
        on_attach = lsp_utils.on_attach,
      })

      vim.lsp.enable('lua_ls')
      vim.lsp.enable('emmet_ls')
      vim.lsp.enable('clangd')
      vim.lsp.enable('ts_ls')
      vim.lsp.enable('html')
      vim.lsp.enable('pyright')

			-- asm_lsp: installed via mason, enable for assembly files
			vim.lsp.config('asm_lsp', {
				capabilities = capabilities,
				on_attach = lsp_utils.on_attach,
			})
      vim.lsp.enable('asm_lsp')

			--
			--
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

			-- Wrap hover in pcall so treesitter rendering errors don't break the UI
			vim.keymap.set("n", "K", function()
				local ok, err = pcall(vim.lsp.buf.hover)
				if not ok then
					vim.notify("LSP hover error: " .. tostring(err), vim.log.levels.WARN)
				end
			end, { desc = "Show hover information" })
		end,
	},
}
