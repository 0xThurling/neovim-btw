local wk = require("which-key")

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your default settings here
	},
	config = function()
    wk.add({
      { "<leader>g", group = "Go To", desc = "Go To" },
      { "<leader>gd", desc = "Definition" },
      { "<leader>gr", desc = "References" },
      { "<leader>gi", desc = "Implementation" },
      { "<leader>r", group = "Rename", desc = "Rename" },
      { "<leader>rn", desc = "Rename" },
      { "<leader>c", group="Code",desc = "Code" },
      { "<leader>ca", desc = "Actions" },
      { "<leader>e", group="Error",desc = "Error" },
      { "<leader>h", group="Harpoon",desc = "Harpoon" },
      { "<leader>f", group="Telescope",desc = "Telescope" },
      { "<leader>t", group="Terminal",desc = "Terminal" },
    })
  end,
}
