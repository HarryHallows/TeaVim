-- TeaVim cheatsheet — a flat, grouped leader-key reference.
-- Open with <leader>K.

local M = {}

-- ── Sections ──────────────────────────────────────────────────────────────────
-- Each section has a title and a list of { lhs, desc } pairs.
-- Entries are only added when their feature flag is active (checked at open
-- time so the cheatsheet always reflects the current profile/features).

local function build_lines()
  local sections = {}

  local function section(title, entries)
    if #entries > 0 then
      table.insert(sections, { title = title, entries = entries })
    end
  end

  -- ── General ──────────────────────────────────────────────────────────────
  section("General", {
    { "<leader>w",  "Save file" },
    { "<leader>q",  "Quit" },
    { "<leader>Q",  "Force quit all" },
    { "<leader>?",  "Open onboarding" },
    { "<leader>K",  "Open cheatsheet (this)" },
    { "<leader>L",  "Open Lazy plugin manager" },
    { "<leader>p",  "Command palette" },
  })

  -- ── Buffers ───────────────────────────────────────────────────────────────
  section("Buffers", {
    { "Shift+H",    "Previous buffer" },
    { "Shift+L",    "Next buffer" },
    { "<leader>bd", "Delete buffer" },
  })

  -- ── Windows ───────────────────────────────────────────────────────────────
  section("Windows", {
    { "Ctrl+H", "Move to left window" },
    { "Ctrl+J", "Move to window below" },
    { "Ctrl+K", "Move to window above" },
    { "Ctrl+L", "Move to right window" },
  })

  -- ── UI ────────────────────────────────────────────────────────────────────
  section("UI", {
    { "<leader>un", "Toggle line numbers" },
    { "<leader>ur", "Toggle relative numbers" },
    { "<leader>uw", "Toggle line wrap" },
    { "<leader>ut", "Theme picker" },
  })

  -- ── Explorer ──────────────────────────────────────────────────────────────
  if TeaVim.features.explorer then
    section("Explorer", {
      { "<leader>e",  "Toggle file explorer" },
      { "<leader>ef", "Reveal current file" },
      { "<leader>eg", "Git status tree" },
    })
  end

  -- ── Find (Telescope) ─────────────────────────────────────────────────────
  if TeaVim.features.fuzzy then
    section("Find", {
      { "<leader>ff", "Find files" },
      { "<leader>fg", "Live grep" },
      { "<leader>fb", "Open buffers" },
      { "<leader>fr", "Recent files" },
      { "<leader>fc", "Commands" },
      { "<leader>fh", "Help tags" },
      { "<leader>fd", "Diagnostics" },
      { "<leader>fs", "Document symbols" },
      { "<leader>fw", "Workspace symbols" },
    })
  end

  -- ── Search & Replace ─────────────────────────────────────────────────────
  if TeaVim.features.search then
    section("Search & Replace", {
      { "<leader>sr", "Find & replace in project" },
      { "<leader>sw", "Search current word / selection" },
      { "<leader>sf", "Search in current file" },
    })
  end

  -- ── LSP ───────────────────────────────────────────────────────────────────
  if TeaVim.features.lsp then
    section("LSP", {
      { "gd",         "Go to definition" },
      { "gD",         "Go to declaration" },
      { "gr",         "References" },
      { "gi",         "Go to implementation" },
      { "gy",         "Go to type definition" },
      { "K",          "Hover docs" },
      { "<leader>la", "Code action" },
      { "<leader>lr", "Rename symbol" },
      { "<leader>lf", "Format file" },
      { "<leader>li", "LSP info" },
      { "<leader>lm", "Open Mason" },
      { "<leader>lR", "Restart LSP" },
      { "<leader>xd", "Line diagnostics" },
      { "]d",         "Next diagnostic" },
      { "[d",         "Prev diagnostic" },
    })
  end

  -- ── Git ───────────────────────────────────────────────────────────────────
  section("Git", {
    { "<leader>gs", "Source control panel" },
    { "<leader>gh", "Preview hunk" },
    { "<leader>gb", "Blame line" },
    { "]h",         "Next hunk" },
    { "[h",         "Prev hunk" },
  })

  -- ── Terminal ──────────────────────────────────────────────────────────────
  if TeaVim.features.terminal then
    section("Terminal", {
      { "<leader>tm",  "Terminal manager" },
      { "Ctrl+\\",     "Terminal manager" },
      { "<leader>tf",  "Float terminal" },
      { "<leader>th",  "Horizontal terminal" },
      { "<leader>tv",  "Vertical terminal" },
      { "<leader>tn",  "New terminal" },
      { "Esc Esc",     "Exit terminal mode" },
    })
  end

  -- ── Debug ─────────────────────────────────────────────────────────────────
  if TeaVim.features.debug then
    section("Debug", {
      { "F5",         "Continue / Start" },
      { "Shift+F5",   "Stop" },
      { "F10",        "Step over" },
      { "F11",        "Step into" },
      { "Shift+F11",  "Step out" },
      { "<leader>db", "Toggle breakpoint" },
      { "<leader>dB", "Conditional breakpoint" },
      { "<leader>dl", "Log point" },
      { "<leader>dL", "Clear all breakpoints" },
      { "<leader>du", "Toggle debug UI" },
      { "<leader>de", "Eval expression / selection" },
      { "<leader>dr", "Open REPL" },
      { "<leader>dR", "Run last" },
    })
  end

  -- ── Motion helpers ────────────────────────────────────────────────────────
  section("Motion & Editing", {
    { "Ctrl+D",      "Scroll down (centred)" },
    { "Ctrl+U",      "Scroll up (centred)" },
    { "J (visual)",  "Move selection down" },
    { "K (visual)",  "Move selection up" },
    { "<leader>p",   "Paste without clobbering register" },
    { "Ctrl+click",  "Go to definition" },
  })

  return sections
end

-- ── Rendering ─────────────────────────────────────────────────────────────────

local function render(sections)
  local lines = {}
  local highlights = {} -- { line, col_start, col_end, hl_group }

  local function push(text, hl)
    local lnum = #lines -- 0-indexed for nvim_buf_add_highlight
    table.insert(lines, text)
    if hl then
      table.insert(highlights, { lnum, 0, #text, hl })
    end
  end

  push("  TeaVim Cheatsheet  —  q / Esc to close", "Title")
  push(string.rep("─", 52), "Comment")

  for _, sec in ipairs(sections) do
    push("")
    push("  " .. sec.title, "TeaVimCheatSection")
    push(string.rep("─", 52), "Comment")
    for _, entry in ipairs(sec.entries) do
      local lhs  = entry[1]
      local desc = entry[2]
      -- Right-align lhs in a 20-char column
      local pad  = math.max(0, 20 - #lhs)
      local line = string.rep(" ", pad) .. lhs .. "  │  " .. desc
      push(line, nil)
      -- Highlight just the lhs portion
      local lnum = #lines - 1
      table.insert(highlights, { lnum, pad, pad + #lhs, "TeaVimCheatKey" })
      -- Highlight the separator
      table.insert(highlights, { lnum, pad + #lhs + 2, pad + #lhs + 5, "Comment" })
    end
  end

  push("")
  push("  q / <Esc>  close    Ctrl+F  search", "Comment")

  return lines, highlights
end

-- ── Float window ──────────────────────────────────────────────────────────────

function M.open()
  local sections      = build_lines()
  local lines, hls    = render(sections)

  local width  = 60
  local height = math.min(#lines, math.floor(vim.o.lines * 0.85))
  local row    = math.floor((vim.o.lines  - height) / 2)
  local col    = math.floor((vim.o.columns - width)  / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype    = "nofile"
  vim.bo[buf].filetype   = "teavim-cheatsheet"

  -- Define highlights (safe to call multiple times — nvim dedupes)
  vim.api.nvim_set_hl(0, "TeaVimCheatSection", { link = "Function", default = true })
  vim.api.nvim_set_hl(0, "TeaVimCheatKey",     { link = "Keyword",  default = true })

  for _, h in ipairs(hls) do
    vim.api.nvim_buf_add_highlight(buf, -1, h[4], h[1], h[2], h[3])
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width    = width,
    height   = height,
    row      = row,
    col      = col,
    style    = "minimal",
    border   = "rounded",
    title    = " ☕ TeaVim Cheatsheet ",
    title_pos = "center",
  })

  vim.wo[win].wrap        = false
  vim.wo[win].cursorline  = true
  vim.wo[win].scrolloff   = 3

  -- Keymaps inside the float
  local close = function() vim.api.nvim_win_close(win, true) end
  local opts  = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "q",   close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
  -- Forward Ctrl+F to built-in search so users can filter
  vim.keymap.set("n", "<C-f>", "/", { buffer = buf, silent = true })
end

return M
