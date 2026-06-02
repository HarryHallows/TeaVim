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
  map({ "n", "i" }, "<C-S-p>", function() require("teavim.ui.palette").open() end, { desc = "Command palette" })
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

-- ── Leader feature bindings (normal mode, mirrors vim/vscode profiles) ────────

if TeaVim.features.fuzzy then
  map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",           { desc = "Find files" })
  map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",            { desc = "Live grep" })
  map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",              { desc = "Open buffers" })
  map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",            { desc = "Help tags" })
  map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",             { desc = "Recent files" })
  map("n", "<leader>fc", "<cmd>Telescope commands<cr>",             { desc = "Commands" })
  map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>",          { desc = "Diagnostics" })
  map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })
end

if TeaVim.features.explorer then
  map("n", "<leader>e",  "<cmd>Neotree toggle<cr>",      { desc = "Toggle file explorer" })
  map("n", "<leader>ef", "<cmd>Neotree reveal<cr>",      { desc = "Reveal current file" })
  map("n", "<leader>eg", "<cmd>Neotree git_status<cr>",  { desc = "Git status tree" })
end

if TeaVim.features.terminal then
  map("n", "<leader>tt", "<cmd>ToggleTerm<cr>",                        { desc = "Toggle terminal" })
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",        { desc = "Float terminal" })
  map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",   { desc = "Horizontal terminal" })
  map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",     { desc = "Vertical terminal" })
  map("n", "<leader>tn", function()
    local terms = require("toggleterm.terminal").get_all(true)
    local max = 0
    for _, t in ipairs(terms) do if t.id > max then max = t.id end end
    vim.cmd((max + 1) .. "ToggleTerm direction=float")
  end, { desc = "New terminal" })
end

if TeaVim.features.lsp then
  map("n", "<leader>la", vim.lsp.buf.code_action,    { desc = "Code action" })
  map("n", "<leader>lr", vim.lsp.buf.rename,         { desc = "Rename symbol" })
  map("n", "<leader>lf", vim.lsp.buf.format,         { desc = "Format file" })
  map("n", "<leader>li", "<cmd>LspInfo<cr>",         { desc = "LSP info" })
  map("n", "<leader>lm", "<cmd>Mason<cr>",           { desc = "Open Mason" })
  map("n", "gd",         vim.lsp.buf.definition,     { desc = "Go to definition" })
  map("n", "gD",         vim.lsp.buf.declaration,    { desc = "Go to declaration" })
  map("n", "gr",         vim.lsp.buf.references,     { desc = "References" })
  map("n", "gi",         vim.lsp.buf.implementation, { desc = "Go to implementation" })
  map("n", "<leader>xd", vim.diagnostic.open_float,  { desc = "Line diagnostics" })
  map("n", "]d",         vim.diagnostic.goto_next,   { desc = "Next diagnostic" })
  map("n", "[d",         vim.diagnostic.goto_prev,   { desc = "Prev diagnostic" })
end

-- Git
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>",   { desc = "Blame line" })
map("n", "]h",         "<cmd>Gitsigns next_hunk<cr>",    { desc = "Next hunk" })
map("n", "[h",         "<cmd>Gitsigns prev_hunk<cr>",    { desc = "Prev hunk" })

-- Open shortcuts panel with ?
map({ "n", "i" }, "?", "<cmd>WhichKey<cr>", { desc = "Show all shortcuts" })
