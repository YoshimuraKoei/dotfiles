local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local rep = require("luasnip.extras").rep

return {
  s("beg", {
    t "\\begin{",
    i(1, "environment"),
    t { "}", "  " },
    i(0),
    t { "", "\\end{" },
    rep(1),
    t "}",
  }),

  s("item", {
    t { "\\begin{itemize}", "  \\item " },
    i(0),
    t { "", "\\end{itemize}" },
  }),

  s("enum", {
    t { "\\begin{enumerate}", "  \\item " },
    i(0),
    t { "", "\\end{enumerate}" },
  }),
}
