vim.o.paste = false
vim.opt.clipboard:prepend({ unnamed = true })

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
