-- Sensible defaults that apply across all profiles.
local o = vim.opt

o.number         = true
o.relativenumber = true
o.signcolumn     = "yes"
o.cursorline     = true
o.termguicolors  = true
o.scrolloff      = 8
o.sidescrolloff  = 8
o.wrap           = false
o.tabstop        = 2
o.shiftwidth     = 2
o.expandtab      = true
o.smartindent    = true
o.ignorecase     = true
o.smartcase      = true
o.hlsearch       = true
o.incsearch      = true
o.splitbelow     = true
o.splitright     = true
o.updatetime     = 200
o.timeoutlen     = 300
o.undofile       = true
o.clipboard      = "unnamedplus"
o.completeopt    = { "menu", "menuone", "noselect" }
o.mouse          = "a"
o.showmode       = false  -- lualine shows mode instead
o.laststatus     = 3      -- global statusline

vim.g.mapleader      = TeaVim.leader
vim.g.maplocalleader = TeaVim.leader

