-- Profile: "vscode"
-- Vim modes are fully preserved. VSCode-familiar shortcuts are layered on top
-- so muscle memory from VSCode works without giving up Vim motions.

local map = vim.keymap.set

-- ── VSCode-familiar shortcuts (work in normal + insert + visual) ──────────────

-- Save / quit
map({ "n", "i", "v" }, "<C-s>",     "<cmd>w<cr><Esc>",  { desc = "Save file" })
map({ "n", "i" },       "<C-S-s>",  "<cmd>wa<cr><Esc>", { desc = "Save all files" })

-- Undo / redo (Ctrl+Z / Ctrl+Y in insert & normal)
map({ "n", "i" }, "<C-z>", "<cmd>undo<cr>",  { desc = "Undo" })
map({ "n", "i" }, "<C-y>", "<cmd>redo<cr>",  { desc = "Redo" })

-- Cut / copy / paste using system clipboard
map({ "n", "v" }, "<C-c>", '"+y',             { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-x>", '"+d',             { desc = "Cut to clipboard" })
map({ "n", "i" }, "<C-v>", '<Esc>"+pa',       { desc = "Paste from clipboard" })

-- Select all
map({ "n", "i" }, "<C-a>", "<Esc>ggVG",       { desc = "Select all" })

-- Duplicate line (Shift+Alt+Down in VSCode)
map({ "n", "i" }, "<S-A-Down>", "<cmd>t.<cr>", { desc = "Duplicate line down" })

-- Move lines up/down (Alt+Up/Down)
map("n", "<A-Up>",   "<cmd>m .-2<cr>==",         { desc = "Move line up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==",          { desc = "Move line down" })
map("i", "<A-Up>",   "<Esc><cmd>m .-2<cr>==gi",  { desc = "Move line up" })
map("i", "<A-Down>", "<Esc><cmd>m .+1<cr>==gi",  { desc = "Move line down" })
map("v", "<A-Up>",   ":m '<-2<cr>gv=gv",          { desc = "Move selection up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv",          { desc = "Move selection down" })

-- Comment toggle (Ctrl+/)
map({ "n", "i" }, "<C-/>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment" })
map("v", "<C-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { desc = "Toggle comment (selection)" })

-- Close tab / buffer (Ctrl+W)
map({ "n", "i" }, "<C-w>", function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 1 then vim.cmd("bprevious") end
  vim.cmd("bdelete #")
end, { desc = "Close buffer" })

-- Split editor (Ctrl+\)
map("n", "<C-\\>", "<cmd>vsplit<cr>", { desc = "Split editor right" })

-- New file (Ctrl+N)
map({ "n", "i" }, "<C-n>", "<cmd>enew<cr>", { desc = "New file" })

-- ── Feature integrations ──────────────────────────────────────────────────────

if TeaVim.features.fuzzy then
  -- Ctrl+P: quick file open (the most-used VSCode shortcut)
  map({ "n", "i" }, "<C-p>",       "<cmd>Telescope find_files<cr>",   { desc = "Find files" })
  -- Ctrl+Shift+F: search in project
  map({ "n", "i" }, "<C-S-f>",     "<cmd>Telescope live_grep<cr>",    { desc = "Find in project" })
  -- Ctrl+Shift+P: command palette
  map({ "n", "i" }, "<C-S-p>", function() require("teavim.ui.palette").open() end, { desc = "Command palette" })
  -- Ctrl+Tab: switch buffers
  map({ "n", "i" }, "<C-Tab>",     "<cmd>Telescope buffers<cr>",      { desc = "Switch buffer" })

  -- Leader fuzzy group
  map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",            { desc = "Find files" })
  map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",             { desc = "Live grep" })
  map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",               { desc = "Open buffers" })
  map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",             { desc = "Help tags" })
  map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",              { desc = "Recent files" })
  map("n", "<leader>fc", "<cmd>Telescope commands<cr>",              { desc = "Commands" })
  map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>",           { desc = "Diagnostics" })
  map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",  { desc = "Document symbols" })
end

if TeaVim.features.explorer then
  -- Ctrl+B: toggle sidebar (matches VSCode)
  map({ "n", "i" }, "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
  map("n", "<leader>e",  "<cmd>Neotree toggle<cr>",      { desc = "Toggle file explorer" })
  map("n", "<leader>ef", "<cmd>Neotree reveal<cr>",      { desc = "Reveal current file" })
  map("n", "<leader>eg", "<cmd>Neotree git_status<cr>",  { desc = "Git status tree" })
end

if TeaVim.features.terminal then
  -- Ctrl+`: toggle terminal (matches VSCode)
  map({ "n", "i" }, "<C-`>",        "<cmd>ToggleTerm<cr>",                     { desc = "Toggle terminal" })
  map("n",          "<leader>tt",   "<cmd>ToggleTerm<cr>",                     { desc = "Toggle terminal" })
  map("n",          "<leader>tf",   "<cmd>ToggleTerm direction=float<cr>",     { desc = "Float terminal" })
  map("n",          "<leader>th",   "<cmd>ToggleTerm direction=horizontal<cr>",{ desc = "Horizontal terminal" })
  map("n",          "<leader>tv",   "<cmd>ToggleTerm direction=vertical<cr>",  { desc = "Vertical terminal" })
  map("n",          "<leader>tn",   function()
    local terms = require("toggleterm.terminal").get_all(true)
    local max = 0
    for _, t in ipairs(terms) do if t.id > max then max = t.id end end
    vim.cmd((max + 1) .. "ToggleTerm direction=float")
  end, { desc = "New terminal" })
  map("t",          "<Esc><Esc>",   "<C-\\><C-n>",                             { desc = "Exit terminal mode" })
end

if TeaVim.features.lsp then
  -- F2: rename (matches VSCode)
  map("n", "<F2>",        vim.lsp.buf.rename,           { desc = "Rename symbol" })
  -- F12: go to definition
  map("n", "<F12>",       vim.lsp.buf.definition,       { desc = "Go to definition" })
  -- Shift+F12: references
  map("n", "<S-F12>",     vim.lsp.buf.references,       { desc = "References" })
  -- Ctrl+.: code actions (matches VSCode quick fix)
  map({ "n", "i" }, "<C-.>", vim.lsp.buf.code_action,  { desc = "Code action / quick fix" })
  -- Alt+Shift+F: format (matches VSCode)
  map({ "n", "i" }, "<A-S-f>", vim.lsp.buf.format,     { desc = "Format document" })
  -- Hover docs on K
  map("n", "K",           vim.lsp.buf.hover,            { desc = "Hover docs" })

  -- Leader LSP group
  map("n", "<leader>la", vim.lsp.buf.code_action,       { desc = "Code action" })
  map("n", "<leader>lr", vim.lsp.buf.rename,            { desc = "Rename symbol" })
  map("n", "<leader>lf", vim.lsp.buf.format,            { desc = "Format file" })
  map("n", "<leader>li", "<cmd>LspInfo<cr>",            { desc = "LSP info" })
  map("n", "<leader>lm", "<cmd>Mason<cr>",              { desc = "Open Mason" })
  map("n", "gd",         vim.lsp.buf.definition,        { desc = "Go to definition" })
  map("n", "gD",         vim.lsp.buf.declaration,       { desc = "Go to declaration" })
  map("n", "gr",         vim.lsp.buf.references,        { desc = "References" })
  map("n", "gi",         vim.lsp.buf.implementation,    { desc = "Go to implementation" })
  map("n", "<leader>xd", vim.diagnostic.open_float,     { desc = "Line diagnostics" })
  map("n", "]d",         vim.diagnostic.goto_next,      { desc = "Next diagnostic" })
  map("n", "[d",         vim.diagnostic.goto_prev,      { desc = "Prev diagnostic" })
end

-- Git (gitsigns)
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>",  { desc = "Preview hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>",    { desc = "Blame line" })
map("n", "]h",         "<cmd>Gitsigns next_hunk<cr>",     { desc = "Next hunk" })
map("n", "[h",         "<cmd>Gitsigns prev_hunk<cr>",     { desc = "Prev hunk" })
