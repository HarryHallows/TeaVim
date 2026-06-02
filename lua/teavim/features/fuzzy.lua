local telescope = require("telescope")
local actions   = require("telescope.actions")

telescope.setup({
  defaults = {
    prompt_prefix   = "  ",
    selection_caret = " ",
    border          = true,
    borderchars     = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    layout_strategy = "horizontal",
    layout_config   = { preview_width = 0.55, width = 0.87, height = 0.80 },
    mappings = {
      i = {
        ["<C-j>"]   = actions.move_selection_next,
        ["<C-k>"]   = actions.move_selection_previous,
        ["<Esc>"]   = actions.close,
        ["<C-u>"]   = false,  -- clear prompt
        ["<C-d>"]   = actions.delete_buffer,
      },
    },
    file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },
    vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename",
      "--line-number", "--column", "--smart-case", "--hidden",
    },
  },
  pickers = {
    find_files   = { hidden = true },
    live_grep    = { additional_args = { "--hidden" } },
  },
})

pcall(telescope.load_extension, "fzf")
