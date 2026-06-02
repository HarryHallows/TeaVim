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

-- gf in normal mode inside any terminal buffer opens the file:line under cursor.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.keymap.set("n", "gf", open_file_from_terminal_line, {
      buffer  = ev.buf,
      silent  = true,
      desc    = "Open file under cursor from terminal output",
    })
  end,
})
