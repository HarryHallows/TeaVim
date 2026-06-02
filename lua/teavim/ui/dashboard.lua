local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- 3D-angled teacup art
local art = {
  [[                                                    ]],
  [[          ______________________________            ]],
  [[        /                              /|           ]],
  [[       /                              / |           ]],
  [[      /______________________________/  |           ]],
  [[      |  .------------------------. |  |           ]],
  [[      | |   ~  ~  ~  ~  ~  ~  ~  | |  |           ]],
  [[      | |  ~  ~  ~  ~  ~  ~  ~   | |  |           ]],
  [[      | |   ~  ~   ___   ~  ~  ~ | | /            ]],
  [[      | |  ~  ~   (   )  ~  ~  ~ | |/   )         ]],
  [[      | |   ~  ~   `-'   ~  ~  ~ | /   (|         ]],
  [[      | |________________________|/   __|          ]],
  [[      |/____________________________/  \           ]],
  [[       \____________________________\__/           ]],
  [[           \________________________/              ]],
  [[                                                    ]],
}

local header = {
  type = "text",
  val  = art,
  opts = { position = "center", hl = "TeaVimLogo" },
}

local title = {
  type = "text",
  val  = "  TeaVim",
  opts = { position = "center", hl = "TeaVimTitle" },
}

local function button(sc, txt, cmd)
  local b = dashboard.button(sc, txt, cmd)
  b.opts.hl          = "TeaVimButton"
  b.opts.hl_shortcut = "TeaVimShortcut"
  return b
end

local buttons = {
  type = "group",
  val = {
    button("e", "  New file",        "<cmd>ene <BAR> startinsert<CR>"),
    button("f", "  Find file",       "<cmd>Telescope find_files<CR>"),
    button("r", "  Recent files",    "<cmd>Telescope oldfiles<CR>"),
    button("g", "  Find text",       "<cmd>Telescope live_grep<CR>"),
    button("l", "  Lazy",            "<cmd>Lazy<CR>"),
    button("q", "  Quit",            "<cmd>qa<CR>"),
  },
  opts = { spacing = 1 },
}

local footer = {
  type = "text",
  val  = "☕  brew something great",
  opts = { position = "center", hl = "TeaVimFooter" },
}

local layout = {
  { type = "padding", val = 3 },
  header,
  { type = "padding", val = 1 },
  title,
  { type = "padding", val = 2 },
  buttons,
  { type = "padding", val = 1 },
  footer,
}

alpha.setup({ layout = layout, opts = {} })

-- Highlight groups (use existing theme colours so they work in any colorscheme)
vim.api.nvim_set_hl(0, "TeaVimLogo",     { fg = "#7aa2f7", bold = false })
vim.api.nvim_set_hl(0, "TeaVimTitle",    { fg = "#bb9af7", bold = true  })
vim.api.nvim_set_hl(0, "TeaVimButton",   { fg = "#c0caf5" })
vim.api.nvim_set_hl(0, "TeaVimShortcut", { fg = "#7aa2f7", bold = true  })
vim.api.nvim_set_hl(0, "TeaVimFooter",   { fg = "#565f89", italic = true })
