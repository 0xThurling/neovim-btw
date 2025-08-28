local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
  s("page", {
    t('@page "'),
    i(1, "/my-page"),
    t('"\n\n'),
    t('@code {\n\t'),
    i(0),
    t('\n}')
  }),
}