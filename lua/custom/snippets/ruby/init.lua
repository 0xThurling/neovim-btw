local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node

return {
  s("puts", {t('puts "'), i(1, "message"), t('"')}),
  s("p", {t('p "'), i(1, "message"), t('"')}),
}