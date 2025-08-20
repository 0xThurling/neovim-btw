local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node

return {
  s("logd", {t("logging.debug('"), i(1, "message"), t("')")}),
  s("logi", {t("logging.info('"), i(1, "message"), t("')")}),
  s("logw", {t("logging.warning('"), i(1, "message"), t("')")}),
  s("loge", {t("logging.error('"), i(1, "message"), t("')")}),
}