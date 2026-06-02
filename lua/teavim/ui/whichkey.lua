-- which-key configuration: provides the discoverable shortcuts panel.
-- Press <Space> in normal mode (or ? in vscode_pure) to open it.

local wk = require("which-key")

wk.setup({
  preset  = "modern",
  delay   = 300,
  plugins = { spelling = { enabled = true } },
  win     = { border = "rounded" },
})

-- Top-level group labels so the panel is readable at a glance.
wk.add({
  { "<leader>b", group = "Buffers" },
  { "<leader>f", group = "Find (fuzzy)" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "LSP" },
  { "<leader>t", group = "Terminal" },
  { "<leader>e", group = "Explorer" },
  { "<leader>x", group = "Diagnostics" },
  { "<leader>u", group = "UI toggles" },
  { "<leader>U", group = "Update TeaVim" },
})

-- UI toggles available in all profiles
local map = vim.keymap.set
map("n", "<leader>un", "<cmd>set number!<cr>",         { desc = "Toggle line numbers" })
map("n", "<leader>ur", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative numbers" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>",           { desc = "Toggle line wrap" })
