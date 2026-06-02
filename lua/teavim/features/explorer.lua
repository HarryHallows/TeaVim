require("neo-tree").setup({
  close_if_last_window    = true,
  popup_border_style      = "rounded",
  enable_git_status       = true,
  enable_diagnostics      = true,
  -- Never auto-open; never hijack netrw directory opens.
  hijack_netrw_behavior   = "disabled",
  window = {
    width    = 35,
    position = "left",
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles   = false,
      hide_gitignored = false,
    },
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  buffers = {
    follow_current_file = { enabled = true },
  },
  git_status = {
    window = { position = "float" },
  },
  default_component_configs = {
    indent = { indent_size = 2 },
    icon   = { folder_closed = "", folder_open = "", folder_empty = "" },
    git_status = {
      symbols = {
        added     = "",
        modified  = "",
        deleted   = "✖",
        renamed   = "➜",
        untracked = "★",
        ignored   = "◌",
        unstaged  = "✗",
        staged    = "✓",
        conflict  = "",
      },
    },
  },
})
