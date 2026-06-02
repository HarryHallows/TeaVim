-- Profile: "vscode_pure"
-- VSCode-style shortcuts in all modes. Normal mode is fully accessible —
-- Escape works as expected to leave insert mode.
-- Arrow keys, Home/End, Page Up/Down all behave as expected.

local map = vim.keymap.set

-- ── Navigation (no Vim motions needed) ───────────────────────────────────────
map({ "n", "i" }, "<Home>",    "<Esc>^i",          { desc = "Go to line start" })
map({ "n", "i" }, "<End>",     "<Esc>$a",           { desc = "Go to line end" })
map({ "n", "i" }, "<C-Home>",  "<Esc>ggI",          { desc = "Go to file start" })
map({ "n", "i" }, "<C-End>",   "<Esc>G$a",          { desc = "Go to file end" })

-- Word-jump (Ctrl+Left/Right like most editors)
map({ "n", "i" }, "<C-Left>",  "<Esc>bi",           { desc = "Word left" })
map({ "n", "i" }, "<C-Right>", "<Esc>wi",           { desc = "Word right" })

-- ── Editing ───────────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-s>",    "<cmd>w<cr>",          { desc = "Save file" })
map({ "n", "i" }, "<C-S-s>",  "<cmd>wa<cr>",         { desc = "Save all" })
map({ "n", "i" }, "<C-z>",    "<cmd>undo<cr>",        { desc = "Undo" })
map({ "n", "i" }, "<C-y>",    "<cmd>redo<cr>",        { desc = "Redo" })
map({ "n", "v" }, "<C-c>",    '"+y',                  { desc = "Copy" })
map({ "n", "v" }, "<C-x>",    '"+d',                  { desc = "Cut" })
map({ "n", "i" }, "<C-v>",    '<Esc>"+pa',            { desc = "Paste" })
map({ "n", "i" }, "<C-a>",    "<Esc>ggVG",            { desc = "Select all" })
map({ "n", "i" }, "<C-n>",    "<cmd>enew<cr>",        { desc = "New file" })
map({ "n", "i" }, "<C-w>",    "<cmd>bdelete<cr>",     { desc = "Close buffer" })
map({ "n", "i" }, "<C-\\>",   "<cmd>vsplit<cr>",      { desc = "Split right" })

-- Delete word backwards (Ctrl+Backspace)
map("i", "<C-BS>", "<C-w>", { desc = "Delete word back" })

-- Duplicate line
map({ "n", "i" }, "<S-A-Down>", "<cmd>t.<cr>", { desc = "Duplicate line" })

-- Move lines
map({ "n", "i" }, "<A-Up>",   "<Esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map({ "n", "i" }, "<A-Down>", "<Esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })

-- Comment toggle
map({ "n", "i" }, "<C-/>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment" })
map("v", "<C-/>",
  "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { desc = "Toggle comment (selection)" })

-- ── Feature integrations ──────────────────────────────────────────────────────

if TeaVim.features.fuzzy then
  map({ "n", "i" }, "<C-p>",   "<cmd>Telescope find_files<cr>",  { desc = "Find files" })
  map({ "n", "i" }, "<C-S-f>", "<cmd>Telescope live_grep<cr>",   { desc = "Find in project" })
  map({ "n", "i" }, "<C-S-p>", "<cmd>Telescope commands<cr>",    { desc = "Command palette" })
  map({ "n", "i" }, "<C-Tab>", "<cmd>Telescope buffers<cr>",     { desc = "Switch buffer" })
end

if TeaVim.features.explorer then
  map({ "n", "i" }, "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle explorer" })
end

if TeaVim.features.terminal then
  map({ "n", "i" }, "<C-`>",      "<cmd>ToggleTerm<cr>",                      { desc = "Toggle terminal" })
  map({ "n", "i" }, "<C-S-`>",    "<cmd>ToggleTerm direction=float<cr>",      { desc = "Float terminal" })
  map("t",          "<Esc>",      "<C-\\><C-n><cmd>ToggleTerm<cr>",           { desc = "Close terminal" })
end

if TeaVim.features.lsp then
  map({ "n", "i" }, "<F2>",      vim.lsp.buf.rename,          { desc = "Rename symbol" })
  map({ "n", "i" }, "<F12>",     vim.lsp.buf.definition,      { desc = "Go to definition" })
  map({ "n", "i" }, "<S-F12>",   vim.lsp.buf.references,      { desc = "References" })
  map({ "n", "i" }, "<C-.>",     vim.lsp.buf.code_action,     { desc = "Quick fix / code action" })
  map({ "n", "i" }, "<A-S-f>",   vim.lsp.buf.format,          { desc = "Format document" })
  -- Hover docs (mouse-over tooltip equivalent)
  map({ "n", "i" }, "<C-k>",     vim.lsp.buf.hover,           { desc = "Hover docs" })
end

-- Git
map({ "n", "i" }, "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
map({ "n", "i" }, "<leader>gb", "<cmd>Gitsigns blame_line<cr>",   { desc = "Blame line" })

-- Open shortcuts panel with ?
map({ "n", "i" }, "?", "<cmd>WhichKey<cr>", { desc = "Show all shortcuts" })
