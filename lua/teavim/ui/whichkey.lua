-- which-key configuration: provides the discoverable shortcuts panel.
-- Press <Space> in normal mode (or ? in vscode_pure) to open it.

local wk = require("which-key")

wk.setup({
  preset  = "modern",
  delay   = 300,
  plugins = { spelling = { enabled = true } },
  win     = { border = "rounded" },
})

-- UI toggles and palette registered immediately — always available.
local map = vim.keymap.set
map("n", "<leader>un", "<cmd>set number!<cr>",         { desc = "Toggle line numbers" })
map("n", "<leader>ur", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative numbers" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>",           { desc = "Toggle line wrap" })
map("n", "<leader>ut", function() require("teavim.ui.themes").open() end,  { desc = "Theme picker" })
map("n", "<leader>p",  function() require("teavim.ui.palette").open() end, { desc = "Command palette" })

-- Group labels deferred to VimEnter so all profile keymaps are already
-- registered before which-key reads them.
vim.api.nvim_create_autocmd("VimEnter", {
  once     = true,
  callback = function()
    wk.add({
      { "<leader>b", group = "Buffers" },
      { "<leader>e", group = "Explorer" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>l", group = "LSP" },
      { "<leader>p", group = "Command Palette" },
      { "<leader>t", group = "Terminal" },
      { "<leader>u", group = "UI" },
      { "<leader>U", group = "Update TeaVim" },
      { "<leader>x", group = "Diagnostics" },
    })
  end,
})
