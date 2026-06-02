-- Keymaps that apply regardless of profile.
-- Profile-specific keymaps are loaded from teavim/keymaps/<profile>.lua

local map = vim.keymap.set

-- ── Window navigation (universal) ────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- ── Buffer navigation ─────────────────────────────────────────────────────────
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<leader>bd", function()
  -- Switch to another buffer first so the window stays open.
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 1 then vim.cmd("bprevious") end
  vim.cmd("bdelete #")
end, { desc = "Delete buffer" })

-- ── Misc quality-of-life ──────────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>w<cr>",      { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>",      { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<cr>",    { desc = "Force quit all" })

-- Move selected lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centred while scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centred)" })
map("n", "n",     "nzzzv",   { desc = "Next search result (centred)" })
map("n", "N",     "Nzzzv",   { desc = "Prev search result (centred)" })

-- Paste without clobbering register
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- ── Lazy plugin manager ───────────────────────────────────────────────────────
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open Lazy plugin manager" })

-- ── Onboarding re-run ─────────────────────────────────────────────────────────
map("n", "<leader>?", function()
  require("teavim.onboarding").start(true)
end, { desc = "Open TeaVim onboarding" })

-- ── User keymaps (loaded last, always wins) ───────────────────────────────────
pcall(require, "user.keymaps")

-- ── Load profile-specific keymaps ────────────────────────────────────────────
local profile = TeaVim.profile
local ok, _ = pcall(require, "teavim.keymaps." .. profile)
if not ok then
  vim.notify("TeaVim: unknown profile '" .. profile .. "'", vim.log.levels.WARN)
end
