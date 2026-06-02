return {
  {
    'dmtrKovalenko/fff.nvim',
    opts = {
      debug = {
        enabled = true,
        show_scores = true,
      },
    },
    lazy = false,
    keys = {
      {
        "ff",
        function() require('fff').find_files() end,
        desc = 'FFFind files',
      }
    }
  }
}
