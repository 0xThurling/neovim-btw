return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	config = function()
		-- Patch query_predicates to guard against invalidated TSNodes (nil :range method).
		-- This fixes the "attempt to call method 'range' (a nil value)" crash that occurs
		-- when treesitter parses short-lived LSP hover float buffers.
		local ok, qp_path = pcall(function()
			return vim.api.nvim_get_runtime_file("lua/nvim-treesitter/query_predicates.lua", false)[1]
		end)
		if ok and qp_path then
			local content = table.concat(vim.fn.readfile(qp_path), "\n")
			-- Only patch if the unguarded line is still present (idempotent)
			if content:find("vim%.treesitter%.get_node_text%(node, bufnr%):lower%(%)") then
				content = content:gsub(
					"local injection_alias = vim%.treesitter%.get_node_text%(node, bufnr%):lower%(%)%s*\n%s*metadata",
					"local _ok, _text = pcall(vim.treesitter.get_node_text, node, bufnr)\n  if not _ok or not _text then return end\n  local injection_alias = _text:lower()\n  metadata"
				)
				vim.fn.writefile(vim.split(content, "\n"), qp_path)
			end
		end

		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"cpp",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"html",
				"css",
				"javascript",
				"typescript",
				"tsx",
				"c_sharp",
				"markdown",
				"markdown_inline",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		})
	end,
}
