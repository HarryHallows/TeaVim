-- TeaVim user configuration
-- This is the ONLY file you need to edit to customise TeaVim.
-- Copy it to user/config.lua to override without touching the source.

local M = {}

M.config = {
  -- Profile controls your editing style.
  --   "vim"          – pure Vim motions, no VSCode shortcuts
  --   "vscode"       – Vim modes kept, VSCode shortcuts layered on top
  --   "vscode_pure"  – modal-less, behaves like a normal text editor
  profile = "vscode",

  -- Feature flags – set to false to disable a feature entirely.
  -- Disabled features add zero startup cost (their plugins never load).
  features = {
    explorer  = true,   -- neo-tree  : file tree sidebar
    fuzzy     = true,   -- telescope : fuzzy find files, text, commands
    terminal  = true,   -- toggleterm: floating/split embedded terminal
    lsp       = true,   -- lspconfig + blink.cmp: language servers + completion
    debug     = true,   -- nvim-dap + dap-ui: breakpoints and step-through debugging
    search    = true,   -- spectre   : project-wide find & replace
  },

  -- Onboarding – shown on first launch, skipped on subsequent ones.
  -- Set to false to permanently suppress, "force" to always show.
  onboarding = true,

  -- Colorscheme. Change via <Space>ut or set here directly.
  -- See lua/teavim/ui/themes.lua for the full list of built-in options.
  theme = "tokyonight-night",

  -- Leader key used across all profiles.
  leader = " ",
}

-- Allow a user/config.lua to override any of the above.
local ok, user = pcall(require, "user.config")
if ok and user then
  M.config = vim.tbl_deep_extend("force", M.config, user)
end

-- Expose config globally so every module can reach it without circular deps.
_G.TeaVim = M.config

return M.config
