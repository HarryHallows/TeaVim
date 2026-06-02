-- Assembles the plugin spec based on feature flags and profile, then hands
-- everything to lazy.nvim in a single setup() call.

local cfg = TeaVim

local specs = {
  -- ── Colorschemes (active one eager-loaded, rest lazy) ────────────────────
  { "folke/tokyonight.nvim",      lazy = cfg.theme ~= nil and not cfg.theme:find("tokyonight"), priority = 1000 },
  { "catppuccin/nvim",            lazy = cfg.theme == nil or not cfg.theme:find("catppuccin"),  priority = 1000, name = "catppuccin" },
  { "ellisonleao/gruvbox.nvim",   lazy = cfg.theme ~= "gruvbox",    priority = 1000 },
  { "rose-pine/neovim",           lazy = cfg.theme == nil or not cfg.theme:find("rose%-pine"), priority = 1000, name = "rose-pine" },
  { "rebelot/kanagawa.nvim",      lazy = cfg.theme == nil or not cfg.theme:find("kanagawa"),   priority = 1000 },
  { "shaunsingh/nord.nvim",       lazy = cfg.theme ~= "nord",        priority = 1000 },
  { "Mofiqul/dracula.nvim",       lazy = cfg.theme ~= "dracula",     priority = 1000 },
  { "olimorris/onedarkpro.nvim",  lazy = cfg.theme ~= "onedark",     priority = 1000 },

  {
    -- Applies the active colorscheme after all theme plugins load.
    dir = vim.fn.stdpath("config"), name = "teavim-theme", lazy = false, priority = 999,
    config = function()
      vim.cmd("colorscheme " .. (cfg.theme or "tokyonight-night"))
    end,
  },

  -- ── Always-on UI ──────────────────────────────────────────────────────────
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "auto" } } },

  -- Dashboard / splash screen
  { "goolord/alpha-nvim", event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("teavim.ui.dashboard") end },

  -- which-key: discoverable shortcuts panel
  { "folke/which-key.nvim", event = "VeryLazy",
    config = function() require("teavim.ui.whichkey") end },

  -- Better notifications
  { "rcarriga/nvim-notify", lazy = false,
    config = function()
      vim.notify = require("notify")
      require("notify").setup({ stages = "fade_in_slide_out", timeout = 3000 })
    end },

  -- Indent guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "BufReadPost",
    opts = {} },

  -- Auto-pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Comment toggling (works in all profiles)
  { "numToStr/Comment.nvim", event = "BufReadPost", opts = {} },

  -- Git signs in the gutter
  { "lewis6991/gitsigns.nvim", event = "BufReadPost", opts = {} },

  -- Treesitter syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript",
                             "python", "rust", "go", "html", "css", "json",
                             "bash", "markdown", "markdown_inline" },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },
}

-- ── Optional features ────────────────────────────────────────────────────────

if cfg.features.explorer then
  table.insert(specs, {
    "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    cmd = { "Neotree" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function() require("teavim.features.explorer") end,
  })
end

if cfg.features.fuzzy then
  table.insert(specs, {
    "nvim-telescope/telescope.nvim", tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function() require("teavim.features.fuzzy") end,
  })
end

if cfg.features.terminal then
  table.insert(specs, {
    "akinsho/toggleterm.nvim", version = "*",
    config = function() require("teavim.features.terminal") end,
  })
end

if cfg.features.lsp then
  table.insert(specs, {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "j-hui/fidget.nvim",
    },
    config = function() require("teavim.features.lsp") end,
  })
  table.insert(specs, {
    "saghen/blink.cmp", version = "*",
    opts = {
      keymap  = { preset = "default" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  })
end

-- ── User-defined extra plugins ────────────────────────────────────────────────
local ok, user_plugins = pcall(require, "user.plugins")
if ok and user_plugins then
  for _, spec in ipairs(user_plugins) do
    table.insert(specs, spec)
  end
end

require("lazy").setup(specs, {
  ui = { border = "rounded" },
  change_detection = { enabled = false, notify = false },
  lockfile = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h") .. "/lazy-lock.json",
})
