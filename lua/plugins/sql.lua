return {
  "kristijanhusak/vim-dadbod-ui",
  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-completion",
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.dbs = {
      my_database = 'mysql://root@localhost:3306/testing'
    }

    vim.keymap.set('n', '<leader>d', ':DBUI', { desc = 'Open Dadbod'});
  end,
}
