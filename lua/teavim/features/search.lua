require("spectre").setup({
  open_cmd   = "noswapfile vnew",
  live_update = true,
  style      = "rg",
  mapping    = {
    ["toggle_line"]      = { map = "dd", cmd = "<cmd>lua require('spectre').toggle_line()<cr>",       desc = "Toggle item" },
    ["enter_file"]       = { map = "<cr>", cmd = "<cmd>lua require('spectre.actions').select_entry()<cr>", desc = "Open file" },
    ["send_to_qf"]       = { map = "<leader>q", cmd = "<cmd>lua require('spectre.actions').send_to_qf()<cr>", desc = "Send to quickfix" },
    ["replace_cmd"]      = { map = "<leader>c", cmd = "<cmd>lua require('spectre.actions').replace_cmd()<cr>", desc = "Input replace command" },
    ["run_current_replace"] = { map = "<leader>rc", cmd = "<cmd>lua require('spectre.actions').run_current_replace()<cr>", desc = "Replace current line" },
    ["run_replace"]      = { map = "<leader>R", cmd = "<cmd>lua require('spectre.actions').run_replace()<cr>", desc = "Replace all" },
    ["change_view_mode"] = { map = "<leader>v", cmd = "<cmd>lua require('spectre').change_view()<cr>",  desc = "Change result view" },
    ["toggle_ignore_case"] = { map = "ti", cmd = "<cmd>lua require('spectre').change_options('ignore-case')<cr>", desc = "Toggle ignore case" },
    ["toggle_ignore_hidden"] = { map = "th", cmd = "<cmd>lua require('spectre').change_options('hidden')<cr>", desc = "Toggle search hidden" },
  },
  find_engine = {
    ["rg"] = {
      cmd = "rg",
      args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
      options = {
        ["ignore-case"] = { value = "--ignore-case", icon = "[I]", desc = "ignore case" },
        ["hidden"]      = { value = "--hidden",       icon = "[H]", desc = "hidden file" },
      },
    },
  },
  default = {
    find    = { cmd = "rg", options = {} },
    replace = { cmd = "sed" },
  },
})
