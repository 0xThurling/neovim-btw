local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
  s("class", {
    t("public class "),
    i(1, "MyClass"),
    t({"\n{", "\n\t"}),
    i(0),
    t({"\n}", ""}),
  }),
}

