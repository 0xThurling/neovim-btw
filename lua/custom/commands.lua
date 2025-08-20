local M = {}

-- path to word_list
local list_path = vim.fn.stdpath("config") .. '/lua/custom/word_list.lua'

local function serialize_list_to_file_content(tbl)
  local lines = {
    "-- This list is auto-generated. You can edit it manually",
    "local trigger_words = {"
  }

  for _, word in ipairs(tbl) do
    table.insert(lines, string.format('  "%s",', word))
  end

  table.insert(lines, "}")
  table.insert(lines, "")
  table.insert(lines, "return trigger_words")
  return table.concat(lines, "\n")
end

function M.add_word_to_list(word)
  if not word or word:match("^%s*$") then
    print("No word provided or selected")
    return
  end

  local trigger_words_table = require('custom.word_list')

  for _, existing_word in ipairs(trigger_words_table) do
    if existing_word == word then
      print(string.format("'%s' is already in the list", word))
      return
    end
  end

  table.insert(trigger_words_table, word)
  print(string.format("'%s' activated for this session", word))

  local new_file_content = serialize_list_to_file_content(trigger_words_table)
  vim.fn.writefile(vim.split(new_file_content, '\n'), list_path)
  print(string.format("Saved '%s' for future sessions", word))
end

local function get_visual_selection()
  -- Get the position of the visual selection start and end marks ('< and '>)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  -- Get all the lines that are part of the selection
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- If the selection is only on a single line
  if #lines == 1 then
    return string.sub(lines[1], start_col, end_col)
  end

  -- For multi-line selections, piece it together
  lines[#lines] = string.sub(lines[#lines], 1, end_col) -- Get the beginning of the last line
  lines[1] = string.sub(lines[1], start_col)          -- Get the end of the first line
  return table.concat(lines, "\n")
end

vim.api.nvim_create_user_command(
  'AddWordToList',
  function (opts)
    local word
    if opts.range == 0 then
      print("Error: please highlight a word to add")
      return
    end

    word = get_visual_selection()
    M.add_word_to_list(word)
  end,
  {range = -1, desc = "Add selected word to autocomplete trigger list"}
)

return M
