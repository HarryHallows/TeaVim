-- Terminal manager UI.
-- Owns its shell buffers directly via termopen() — does not use toggleterm's
-- window management, so no stray inline terminals ever appear.
--
-- <leader>tm / <C-\>  open/close the manager
-- j/k                 navigate (switches live preview)
-- <CR>                focus terminal pane (enter insert)
-- <C-\>               return from terminal pane to sidebar
-- b                   toggle sidebar
-- n                   new terminal
-- x                   kill terminal
-- r                   rename terminal
-- <Esc> / q           close manager
-- ?                   keybind tooltip

local M = {}

local _open = false   -- guard against double-open

-- ── Highlights ────────────────────────────────────────────────────────────────

local function setup_hls()
  vim.api.nvim_set_hl(0, "TermSidebarCursor",   { bg = "#2a2e45", bold = true })
  vim.api.nvim_set_hl(0, "TermSidebarActive",   { fg = "#7aa2f7", bold = true })
  vim.api.nvim_set_hl(0, "TermSidebarInactive", { fg = "#a9b1d6" })
  vim.api.nvim_set_hl(0, "TermSidebarId",       { fg = "#e0af68", bold = true })
  vim.api.nvim_set_hl(0, "TermSidebarEmpty",    { italic = true,  fg = "#3b4261" })
  vim.api.nvim_set_hl(0, "TermSidebarHeader",   { bold = true,    fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "TermTooltipBorder",   { fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "TermTooltipKey",      { bold = true,    fg = "#e0af68" })
  vim.api.nvim_set_hl(0, "TermTooltipDesc",     { fg = "#a9b1d6" })
  vim.api.nvim_set_hl(0, "TermTooltipDim",      { italic = true,  fg = "#565f89" })
end

-- ── Shell buffer management ───────────────────────────────────────────────────
-- We manage a simple list of { id, bufnr, name } entries ourselves.
-- toggleterm is left alone — <C-`> etc. still work for quick terminals.

local shells     = {}   -- { id, bufnr, name }[]  ordered by id
local shell_seq  = 0    -- monotonic id counter

local function next_id()
  shell_seq = shell_seq + 1
  return shell_seq
end

local function shell_by_id(id)
  for _, s in ipairs(shells) do
    if s.id == id then return s end
  end
end

local function shell_label(s)
  return s.name or ("terminal " .. s.id)
end

-- Create a new shell buffer (does NOT open any window).
local function create_shell()
  local id  = next_id()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  -- Start the shell job inside this buffer.
  -- We need a scratch window to run termopen() because termopen requires a
  -- current window; we briefly open a minimal split, run it, then close it.
  local cur_win = vim.api.nvim_get_current_win()
  local tmp_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", row = 0, col = 0, width = 10, height = 1,
    style = "minimal", zindex = 1,
  })
  local shell = vim.o.shell
  vim.fn.termopen(shell, {
    on_exit = function()
      -- Remove from list when the shell process exits
      for i, s in ipairs(shells) do
        if s.id == id then
          table.remove(shells, i)
          break
        end
      end
    end,
  })
  vim.api.nvim_win_close(tmp_win, true)
  vim.api.nvim_set_current_win(cur_win)
  -- Name the buffer
  pcall(vim.api.nvim_buf_set_name, buf, "term://teavim/terminal-" .. id)
  local entry = { id = id, bufnr = buf }
  table.insert(shells, entry)
  return entry
end

local function kill_shell(id)
  local s = shell_by_id(id)
  if not s then return end
  if vim.api.nvim_buf_is_valid(s.bufnr) then
    vim.api.nvim_buf_delete(s.bufnr, { force = true })
  end
  for i, sh in ipairs(shells) do
    if sh.id == id then table.remove(shells, i) break end
  end
end

-- ── Sidebar content ───────────────────────────────────────────────────────────

local function build_sidebar(active_id, sidebar_w)
  local lines, hls, id_index = {}, {}, {}

  local function hl(row, group, cs, ce)
    table.insert(hls, { line = row - 1, group = group, cs = cs, ce = ce })
  end

  if #shells == 0 then
    table.insert(lines, "  (no terminals)")
    hl(1, "TermSidebarEmpty", 0, -1)
    table.insert(id_index, nil)
    return lines, hls, id_index
  end

  for _, s in ipairs(shells) do
    local is_active = s.id == active_id
    local marker    = is_active and "▶ " or "  "
    local id_str    = string.format("#%-3d", s.id)
    local label     = shell_label(s)
    local max_lbl   = sidebar_w - #marker - #id_str - 2
    if #label > max_lbl then label = label:sub(1, max_lbl - 1) .. "…" end
    local line = marker .. id_str .. " " .. label
    table.insert(lines, line)
    local row = #lines
    hl(row, is_active and "TermSidebarActive" or "TermSidebarInactive", 0, -1)
    hl(row, "TermSidebarId", #marker, #marker + #id_str)
    table.insert(id_index, s.id)
  end

  return lines, hls, id_index
end

-- ── Open UI ───────────────────────────────────────────────────────────────────

function M.open()
  if _open then return end

  setup_hls()

  -- Ensure at least one shell exists
  if #shells == 0 then
    create_shell()
  end

  local total_w   = math.min(vim.o.columns - 4, 200)
  local height    = math.min(vim.o.lines   - 4, 45)
  local sidebar_w = 28
  local term_w    = total_w - sidebar_w - 3
  local win_row   = math.floor((vim.o.lines   - height) / 2)
  local win_col   = math.floor((vim.o.columns - total_w) / 2)
  local twin_col  = win_col + sidebar_w + 2

  local sidebar_visible = true
  local active_id       = shells[1].id

  -- ── Sidebar window ────────────────────────────────────────────────────────

  local sbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(sbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(sbuf, "buftype",   "nofile")

  local swin = vim.api.nvim_open_win(sbuf, true, {
    relative  = "editor",
    row = win_row, col = win_col,
    width = sidebar_w, height = height,
    style     = "minimal",
    border    = "rounded",
    title     = " Terminals ",
    title_pos = "center",
    zindex    = 50,
  })
  vim.api.nvim_win_set_option(swin, "cursorline",  true)
  vim.api.nvim_win_set_option(swin, "wrap",         false)
  vim.api.nvim_win_set_option(swin, "winhighlight", "CursorLine:TermSidebarCursor")

  -- ── Terminal pane ─────────────────────────────────────────────────────────

  local twin = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
    relative  = "editor",
    row = win_row, col = twin_col,
    width = term_w, height = height,
    style     = "minimal",
    border    = "rounded",
    title     = " Terminal ",
    title_pos = "center",
    zindex    = 50,
  })
  vim.api.nvim_win_set_option(twin, "wrap", false)

  _open = true

  -- ── Close ─────────────────────────────────────────────────────────────────

  local closing = false
  local function close()
    if closing then return end
    closing = true
    _open = false
    -- Exit terminal/insert mode first so we're never left stuck
    local mode = vim.api.nvim_get_mode().mode
    if mode == "t" or mode == "i" then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
    end
    vim.schedule(function()
      pcall(vim.api.nvim_win_close, swin, true)
      pcall(vim.api.nvim_win_close, twin, true)
    end)
  end

  -- ── Terminal pane keymaps ─────────────────────────────────────────────────
  -- Set on each shell buffer when first loaded into the pane.

  local pane_maps_set = {}
  local function set_pane_keymaps(bufnr)
    if pane_maps_set[bufnr] then return end
    pane_maps_set[bufnr] = true
    local o = { buffer = bufnr, noremap = true, silent = true }
    -- <C-\> in terminal mode → exit insert, return to sidebar
    vim.keymap.set("t", "<C-\\>", function()
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(swin) then
          vim.api.nvim_set_current_win(swin)
        end
      end)
    end, o)
    -- Normal mode in pane: Esc/q close the manager
    vim.keymap.set("n", "<Esc>", close, o)
    vim.keymap.set("n", "q",     close, o)
  end

  -- ── Show shell in pane ────────────────────────────────────────────────────

  local function show_in_pane(id)
    if not vim.api.nvim_win_is_valid(twin) then return end
    local s = shell_by_id(id)
    if not s or not vim.api.nvim_buf_is_valid(s.bufnr) then return end
    vim.api.nvim_win_set_buf(twin, s.bufnr)
    set_pane_keymaps(s.bufnr)
    pcall(vim.api.nvim_win_set_config, twin, {
      title = string.format(" %s ", shell_label(s)), title_pos = "center",
    })
  end

  -- ── Sidebar render ────────────────────────────────────────────────────────

  local id_index = {}

  local function render_sidebar(keep_row)
    local prev_row = keep_row
      or (vim.api.nvim_win_is_valid(swin) and vim.api.nvim_win_get_cursor(swin)[1] or 1)

    local lines, hls
    lines, hls, id_index = build_sidebar(active_id, sidebar_w)

    vim.api.nvim_buf_set_option(sbuf, "modifiable", true)
    vim.api.nvim_buf_clear_namespace(sbuf, -1, 0, -1)
    vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, lines)
    for _, h in ipairs(hls) do
      pcall(vim.api.nvim_buf_add_highlight, sbuf, -1, h.group, h.line, h.cs, h.ce)
    end
    vim.api.nvim_buf_set_option(sbuf, "modifiable", false)

    local target = nil
    for i = prev_row, #id_index do if id_index[i] then target = i break end end
    if not target then
      for i = math.min(prev_row, #id_index), 1, -1 do
        if id_index[i] then target = i break end
      end
    end
    if target and vim.api.nvim_win_is_valid(swin) then
      vim.api.nvim_win_set_cursor(swin, { target, 0 })
    end
  end

  local function refresh(keep_row)
    render_sidebar(keep_row)
    show_in_pane(active_id)
  end

  -- ── Navigation ────────────────────────────────────────────────────────────

  local function id_at_cursor()
    if not vim.api.nvim_win_is_valid(swin) then return nil end
    return id_index[vim.api.nvim_win_get_cursor(swin)[1]]
  end

  local function move(delta)
    if not vim.api.nvim_win_is_valid(swin) then return end
    local cur  = vim.api.nvim_win_get_cursor(swin)[1]
    local step = delta > 0 and 1 or -1
    local new  = cur + step
    while new >= 1 and new <= #id_index do
      if id_index[new] then
        active_id = id_index[new]
        vim.api.nvim_win_set_cursor(swin, { new, 0 })
        render_sidebar(new)
        show_in_pane(active_id)
        return
      end
      new = new + step
    end
  end

  -- ── Toggle sidebar ────────────────────────────────────────────────────────

  local function toggle_sidebar()
    if sidebar_visible then
      if vim.api.nvim_win_is_valid(swin) then vim.api.nvim_win_hide(swin) end
      if vim.api.nvim_win_is_valid(twin) then
        pcall(vim.api.nvim_win_set_config, twin, {
          relative = "editor", row = win_row, col = win_col,
          width = total_w, height = height,
        })
      end
      sidebar_visible = false
    else
      if vim.api.nvim_win_is_valid(swin) then
        vim.api.nvim_win_show(swin)
      end
      if vim.api.nvim_win_is_valid(twin) then
        pcall(vim.api.nvim_win_set_config, twin, {
          relative = "editor", row = win_row, col = twin_col,
          width = term_w, height = height,
        })
      end
      vim.api.nvim_set_current_win(swin)
      sidebar_visible = true
    end
  end

  -- ── New / kill / rename ───────────────────────────────────────────────────

  local function new_term()
    local s = create_shell()
    active_id = s.id
    refresh(999)
    -- Move cursor to the new entry
    for i, v in ipairs(id_index) do
      if v == s.id then
        vim.api.nvim_win_set_cursor(swin, { i, 0 })
        break
      end
    end
  end

  local function kill_term()
    local id = id_at_cursor()
    if not id then return end
    kill_shell(id)
    if #shells == 0 then close(); return end
    active_id = shells[1].id
    refresh(1)
  end

  local function rename_term()
    local id = id_at_cursor()
    if not id then return end
    local s = shell_by_id(id)
    if not s then return end
    vim.ui.input({ prompt = "Terminal name: ", default = s.name or "" }, function(name)
      if name == nil then return end
      s.name = name ~= "" and name or nil
      render_sidebar()
    end)
  end

  -- ── Tooltip ───────────────────────────────────────────────────────────────

  local function show_tooltip()
    local lines = {
      "  Keybindings                    ",
      "  ─────────────────────────────  ",
      "  j / k       navigate           ",
      "  <CR>        focus terminal     ",
      "  <C-\\>      back to sidebar    ",
      "  b           toggle sidebar     ",
      "  n           new terminal       ",
      "  x           kill terminal      ",
      "  r           rename terminal    ",
      "  <Esc> / q   close manager      ",
      "  ?           toggle this help   ",
      "                                 ",
      "  any key to dismiss             ",
    }
    local tt_w   = 36
    local tt_h   = #lines
    local tt_row = math.max(0, math.min(win_row + math.floor((height - tt_h) / 2),
                                        vim.o.lines   - tt_h - 2))
    local tt_col = math.max(0, math.min(win_col + sidebar_w + 4,
                                        vim.o.columns - tt_w - 2))

    local ttbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(ttbuf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(ttbuf, "buftype",   "nofile")
    vim.api.nvim_buf_set_lines(ttbuf, 0, -1, false, lines)
    vim.api.nvim_buf_add_highlight(ttbuf, -1, "TermSidebarHeader", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(ttbuf, -1, "TermTooltipDim",    1, 0, -1)
    for i = 2, #lines - 2 do
      local l = lines[i + 1] or ""
      if l:find("  .-  ") then
        local key_end = (l:find("%s%s", 3) or 3) - 1
        vim.api.nvim_buf_add_highlight(ttbuf, -1, "TermTooltipKey",  i, 2, key_end)
        vim.api.nvim_buf_add_highlight(ttbuf, -1, "TermTooltipDesc", i, key_end, -1)
      end
    end
    vim.api.nvim_buf_add_highlight(ttbuf, -1, "TermTooltipDim", #lines - 1, 0, -1)
    vim.api.nvim_buf_set_option(ttbuf, "modifiable", false)

    local ttwin = vim.api.nvim_open_win(ttbuf, false, {
      relative  = "editor",
      row = tt_row, col = tt_col,
      width = tt_w, height = tt_h,
      style = "minimal", border = "rounded",
      title = " Help ", title_pos = "center",
      zindex = 60,
    })
    vim.api.nvim_win_set_option(ttwin, "winhighlight", "FloatBorder:TermTooltipBorder")

    local function close_tt()
      if vim.api.nvim_win_is_valid(ttwin) then vim.api.nvim_win_close(ttwin, true) end
    end
    local tt_opts = { buffer = sbuf, noremap = true, silent = true }
    vim.api.nvim_create_autocmd("CursorMoved",               { buffer = sbuf, once = true, callback = close_tt })
    vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" },{ buffer = sbuf, once = true, callback = close_tt })
    vim.keymap.set("n", "?", function()
      close_tt()
      vim.keymap.set("n", "?", show_tooltip, tt_opts)
    end, tt_opts)
  end

  -- ── Bootstrap ─────────────────────────────────────────────────────────────

  refresh(1)

  -- ── CursorMoved: snap + sync ──────────────────────────────────────────────

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = sbuf,
    callback = function()
      if not vim.api.nvim_win_is_valid(swin) then return end
      local cur = vim.api.nvim_win_get_cursor(swin)[1]
      if id_index[cur] then
        active_id = id_index[cur]
        render_sidebar(cur)
        show_in_pane(active_id)
        return
      end
      local target = nil
      for i = cur + 1, #id_index do if id_index[i] then target = i break end end
      if not target then
        for i = cur - 1, 1, -1 do if id_index[i] then target = i break end end
      end
      if target then
        active_id = id_index[target]
        vim.api.nvim_win_set_cursor(swin, { target, 0 })
        render_sidebar(target)
        show_in_pane(active_id)
      end
    end,
  })

  -- Cleanup when sidebar is wiped
  vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
    buffer = sbuf, once = true,
    callback = function()
      _open = false
      vim.schedule(function() pcall(vim.api.nvim_win_close, twin, true) end)
    end,
  })

  -- ── Keymaps (sidebar) ─────────────────────────────────────────────────────

  local opts = { buffer = sbuf, noremap = true, silent = true }

  vim.keymap.set("n", "j",      function() move(1) end,  opts)
  vim.keymap.set("n", "k",      function() move(-1) end, opts)
  vim.keymap.set("n", "<Down>", function() move(1) end,  opts)
  vim.keymap.set("n", "<Up>",   function() move(-1) end, opts)

  vim.keymap.set("n", "<CR>", function()
    if vim.api.nvim_win_is_valid(twin) then
      vim.api.nvim_set_current_win(twin)
      vim.cmd("startinsert")
    end
  end, opts)

  vim.keymap.set("n", "b", toggle_sidebar, opts)
  vim.keymap.set("n", "n", new_term,       opts)
  vim.keymap.set("n", "x", kill_term,      opts)
  vim.keymap.set("n", "r", rename_term,    opts)
  vim.keymap.set("n", "?", show_tooltip,   opts)
  vim.keymap.set("n", "q",     close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

-- ── Toggle ────────────────────────────────────────────────────────────────────

function M.toggle()
  if _open then
    -- Find and close the sidebar window (triggers the WinClosed cleanup)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative ~= "" then
        local title_tbl = cfg.title
        if type(title_tbl) == "table" and title_tbl[1] then
          local txt = title_tbl[1][1] or ""
          if txt:find("Terminals") then
            local mode = vim.api.nvim_get_mode().mode
            if mode == "t" or mode == "i" then
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
            end
            vim.schedule(function()
              pcall(vim.api.nvim_win_close, win, true)
              _open = false
            end)
            return
          end
        end
      end
    end
    _open = false  -- stale flag; fall through to open
  end
  M.open()
end

return M
