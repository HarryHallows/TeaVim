-- Assembles the plugin spec based on feature flags and profile, then hands
-- everything to lazy.nvim in a single setup() call.

local cfg = TeaVim

local specs = {
  -- ── Always-on UI ──────────────────────────────────────────────────────────
  { "folke/tokyonight.nvim", lazy = false, priority = 1000,
    config = function() vim.cmd("colorscheme tokyonight-night") end },

  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "tokyonight" } } },

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
    main  = "nvim-treesitter.configs",
    opts  = {
      ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript",
                           "python", "rust", "go", "html", "css", "json",
                           "bash", "markdown", "markdown_inline" },
      highlight = { enable = true },
      indent    = { enable = true },
    },
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
  change_detection = { notify = false },
})
