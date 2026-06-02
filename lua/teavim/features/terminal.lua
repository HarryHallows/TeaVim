require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then return 15
    elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
    end
  end,
  open_mapping    = [[<C-`>]],
  hide_numbers    = true,
  shade_terminals = true,
  shading_factor  = 2,
  start_in_insert = true,
  persist_size    = true,
  direction       = "float",
  close_on_exit   = true,
  shell           = vim.o.shell,
  float_opts      = {
    border   = "curved",
    winblend = 3,
  },
})
