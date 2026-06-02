-- Profile: "vim"
-- Pure Vim motions. No VSCode shortcuts are added. This profile is for users
-- who want the full Vim experience with TeaVim's feature integrations.

local map = vim.keymap.set

-- ── Feature integrations (guarded by feature flags) ──────────────────────────

if TeaVim.features.explorer then
  map("n", "<leader>e",  "<cmd>Neotree toggle<cr>",       { desc = "Toggle file explorer" })
  map("n", "<leader>ef", "<cmd>Neotree reveal<cr>",       { desc = "Reveal current file" })
  map("n", "<leader>eg", "<cmd>Neotree git_status<cr>",   { desc = "Git status tree" })
end

if TeaVim.features.fuzzy then
  map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",              { desc = "Find files" })
  map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",               { desc = "Live grep" })
  map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",                 { desc = "Open buffers" })
  map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",               { desc = "Help tags" })
  map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",                { desc = "Recent files" })
  map("n", "<leader>fc", "<cmd>Telescope commands<cr>",                { desc = "Commands" })
  map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>",             { desc = "Diagnostics" })
  map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",   { desc = "Document symbols" })
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
  map("t", "<Esc><Esc>", "<C-\\><C-n>",                               { desc = "Exit terminal mode" })
end

if TeaVim.features.lsp then
  map("n", "<leader>la", vim.lsp.buf.code_action,          { desc = "Code action" })
  map("n", "<leader>lr", vim.lsp.buf.rename,               { desc = "Rename symbol" })
  map("n", "<leader>lf", vim.lsp.buf.format,               { desc = "Format file" })
  map("n", "<leader>li", "<cmd>LspInfo<cr>",               { desc = "LSP info" })
  map("n", "<leader>lm", "<cmd>Mason<cr>",                 { desc = "Open Mason" })
  map("n", "gd",         vim.lsp.buf.definition,           { desc = "Go to definition" })
  map("n", "gD",         vim.lsp.buf.declaration,          { desc = "Go to declaration" })
  map("n", "gr",         vim.lsp.buf.references,           { desc = "References" })
  map("n", "gi",         vim.lsp.buf.implementation,       { desc = "Go to implementation" })
  map("n", "K",          vim.lsp.buf.hover,                { desc = "Hover docs" })
  map("n", "<leader>xd", vim.diagnostic.open_float,        { desc = "Line diagnostics" })
  map("n", "]d",         vim.diagnostic.goto_next,         { desc = "Next diagnostic" })
  map("n", "[d",         vim.diagnostic.goto_prev,         { desc = "Prev diagnostic" })
end

-- Git (gitsigns)
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>",   { desc = "Preview hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>",     { desc = "Blame line" })
map("n", "]h",         "<cmd>Gitsigns next_hunk<cr>",      { desc = "Next hunk" })
map("n", "[h",         "<cmd>Gitsigns prev_hunk<cr>",      { desc = "Prev hunk" })
