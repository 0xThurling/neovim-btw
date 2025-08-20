local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node

return {
  s("cl", {t("console.log('"), i(1, "message"), t("')")}),
  s("cw", {t("console.warn('"), i(1, "message"), t("')")}),
  s("ce", {t("console.error('"), i(1, "message"), t("')")}),
}