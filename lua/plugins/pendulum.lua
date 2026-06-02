return {
	"ptdewey/pendulum-nvim",
	lazy = false,
	config = function()
		require("pendulum").setup({
			-- The CSV file where logs should be written.
			-- Defaults to $HOME/pendulum-log.csv.
			log_file = vim.env.HOME .. "/pendulum-log.csv",
			-- Length of time in seconds to determine inactivity (default is 180).
			timeout_len = 180,
			-- Interval in seconds at which to check activity (default is 120).
			timer_len = 120,
			-- Generate reports from the log file (requires Go, which is installed).
			gen_reports = true,
		})

		-- Keybindings for Pendulum
		vim.keymap.set("n", "<leader>ip", ":Pendulum<CR>", { silent = true, desc = "Pendulum Metrics" })
		vim.keymap.set("n", "<leader>ih", ":PendulumHours<CR>", { silent = true, desc = "Pendulum Active Hours" })
	end,
}
