-- Open file:line under cursor from terminal output (e.g. pytest/compiler traces).
-- Works on lines like:  path/to/file.py:42:  or  /abs/path/file.py:42
local function open_file_from_terminal_line()
  -- Get the current line in terminal mode (normal-mode cursor position).
  local line = vim.api.nvim_get_current_line()

  -- Match optional leading whitespace, then a path, then :line_number
  -- Handles both relative (tests/foo.py:14) and absolute (/home/.../foo.py:14)
  local filepath, lnum = line:match("[%s]*([%w%.%/%-_]+%.%a+):(%d+)")
  if not filepath then
    -- Try without line number
    filepath = line:match("[%s]*([%w%.%/%-_]+%.%a+)")
  end
  if not filepath then
    vim.notify("No file path found on this line", vim.log.levels.WARN)
    return
  end

  -- Resolve relative paths against the terminal's cwd.
  if not filepath:match("^/") then
    local cwd = vim.fn.getcwd()
    filepath = cwd .. "/" .. filepath
  end

  -- Confirm the file exists.
  if vim.fn.filereadable(filepath) == 0 then
    vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
    return
  end

  -- Open in the previous window (the editor, not the terminal split).
  vim.cmd("wincmd p")
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  if lnum then
    vim.api.nvim_win_set_cursor(0, { tonumber(lnum), 0 })
    vim.cmd("normal! zz")
  end
end

require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then return 15
    elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
    end
  end,
  open_mapping    = [[<C-`>]],
  hide_numbers    = true,
  shade_terminals = true,
  shading_factor  = 2,
  start_in_insert = true,
  persist_size    = true,
  direction       = "float",
  close_on_exit   = true,
  shell           = vim.o.shell,
  float_opts      = {
    border   = "curved",
    winblend = 3,
  },
})

-- ── Multi-terminal management ─────────────────────────────────────────────────
local Terminal = require("toggleterm.terminal").Terminal

-- Track the highest terminal id we've opened this session.
local function next_free_id()
  local terms = require("toggleterm.terminal").get_all(true)
  local max = 0
  for _, t in ipairs(terms) do
    if t.id > max then max = t.id end
  end
  return max + 1
end

local function new_term()
  Terminal:new({ id = next_free_id(), direction = "float" }):toggle()
end

local function cycle_term(delta)
  local terms = require("toggleterm.terminal").get_all(true)
  if #terms == 0 then return end
  -- Sort by id so cycling is predictable.
  table.sort(terms, function(a, b) return a.id < b.id end)
  -- Find the currently focused terminal.
  local current_id = vim.b.toggle_number  -- set by toggleterm on every open
  local current_idx = 1
  for i, t in ipairs(terms) do
    if t.id == current_id then current_idx = i break end
  end
  local next_idx = ((current_idx - 1 + delta) % #terms) + 1
  local next = terms[next_idx]
  -- Close the current one without destroying it, open the next.
  vim.cmd("ToggleTerm")          -- hides current
  next:toggle()
end

local function close_term_keep_window()
  local terms = require("toggleterm.terminal").get_all(true)
  if #terms <= 1 then
    -- Only one terminal — just hide it.
    vim.cmd("ToggleTerm")
    return
  end
  -- Delete this terminal's buffer then show the next available one.
  local current_id = vim.b.toggle_number
  vim.cmd("ToggleTerm")  -- hide first so toggleterm cleans up state
  -- Remove from internal list by toggling its count to 0 via delete.
  for _, t in ipairs(terms) do
    if t.id == current_id then
      t:shutdown()
      break
    end
  end
  -- Open the first remaining terminal.
  local remaining = require("toggleterm.terminal").get_all(true)
  table.sort(remaining, function(a, b) return a.id < b.id end)
  if #remaining > 0 then remaining[1]:toggle() end
end

-- Per-terminal buffer keymaps (normal mode inside terminal).
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    -- gf: open file:line under cursor
    vim.keymap.set("n", "gf", open_file_from_terminal_line,
      vim.tbl_extend("force", opts, { desc = "Open file under cursor" }))
    -- <C-t>: spawn a new terminal
    vim.keymap.set({ "n", "t" }, "<C-t>", new_term,
      vim.tbl_extend("force", opts, { desc = "New terminal" }))
    -- <C-]> / <C-[>: cycle next/prev terminal
    vim.keymap.set({ "n", "t" }, "<C-]>", function() cycle_term(1)  end,
      vim.tbl_extend("force", opts, { desc = "Next terminal" }))
    vim.keymap.set({ "n", "t" }, "<C-[>", function() cycle_term(-1) end,
      vim.tbl_extend("force", opts, { desc = "Prev terminal" }))
    -- <C-x>: close this terminal instance (keep window if others exist)
    vim.keymap.set({ "n", "t" }, "<C-x>", close_term_keep_window,
      vim.tbl_extend("force", opts, { desc = "Close terminal" }))
  end,
})
