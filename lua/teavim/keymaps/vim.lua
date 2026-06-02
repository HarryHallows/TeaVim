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
  map("n", "<leader>tm", function() require("teavim.ui.terminal").toggle() end, { desc = "Terminal manager" })
  map("n", "<C-\\>",     function() require("teavim.ui.terminal").toggle() end, { desc = "Terminal manager" })
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

if TeaVim.features.debug then
  local dap    = function() return require("dap") end
  local dapui  = function() return require("dapui") end

  -- Run / stop
  map("n", "<F5>",       function() dap().continue() end,           { desc = "Debug: Continue / Start" })
  map("n", "<F17>",      function() dap().terminate() end,          { desc = "Debug: Stop" })       -- Shift+F5
  -- Step controls
  map("n", "<F10>",      function() dap().step_over() end,          { desc = "Debug: Step Over" })
  map("n", "<F11>",      function() dap().step_into() end,          { desc = "Debug: Step Into" })
  map("n", "<F23>",      function() dap().step_out() end,           { desc = "Debug: Step Out" })   -- Shift+F11
  -- Breakpoints
  map("n", "<leader>db", function() dap().toggle_breakpoint() end,  { desc = "Debug: Toggle Breakpoint" })
  map("n", "<leader>dB", function()
    dap().set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "Debug: Conditional Breakpoint" })
  map("n", "<leader>dl", function()
    dap().set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
  end, { desc = "Debug: Log Point" })
  map("n", "<leader>dL", function() dap().clear_breakpoints() end,  { desc = "Debug: Clear All Breakpoints" })
  -- UI
  map("n", "<leader>du", function() dapui().toggle() end,           { desc = "Debug: Toggle UI" })
  map("n", "<leader>de", function() dapui().eval() end,             { desc = "Debug: Eval expression" })
  map("v", "<leader>de", function() dapui().eval() end,             { desc = "Debug: Eval selection" })
  -- Misc
  map("n", "<leader>dr", function() dap().repl.open() end,          { desc = "Debug: Open REPL" })
  map("n", "<leader>dR", function() dap().run_last() end,           { desc = "Debug: Run Last" })
end

-- Git (gitsigns + source control modal)
map("n", "<leader>gs", function() require("teavim.ui.git").open() end, { desc = "Source control" })
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>",   { desc = "Preview hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>",     { desc = "Blame line" })
map("n", "]h",         "<cmd>Gitsigns next_hunk<cr>",      { desc = "Next hunk" })
map("n", "[h",         "<cmd>Gitsigns prev_hunk<cr>",      { desc = "Prev hunk" })
