vim.o.paste = false
vim.opt.clipboard:prepend({ unnamed = true })

-- Disable built-in treesitter to avoid conflict with nvim-treesitter plugin
-- vim.g.loaded_treesitter = true
-- vim.g.loaded_treesitter_query = true

vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*:*",
	callback = function(args)
		local mode = vim.fn.mode()
		if mode == "\22" then -- Ctrl+v (visual block)
			vim.opt.virtualedit = "all"
		else
			vim.opt.virtualedit = ""
		end
	end,
})

vim.cmd("set t_BE=")
