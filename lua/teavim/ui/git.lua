-- Source control modal.
-- Tab bar switches between Staged / Changes tabs. Files start at row 1.
-- j/k navigate, Space multi-select, s stage, u unstage,
-- A stage all, U unstage all, cc commit, <CR> full diff, r refresh, q/Esc close.

local M = {}

-- ── Git helpers ───────────────────────────────────────────────────────────────

local function git(args)
  return vim.trim(vim.fn.system(
    "git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " " .. args
  ))
end

local function git_ok(args)
  git(args)
  return vim.v.shell_error == 0
end

local function get_status()
  local out = git("status --porcelain=v1 -u")
  local staged, unstaged = {}, {}
  for line in (out .. "\n"):gmatch("([^\n]*)\n") do
    if #line >= 2 then
      local x    = line:sub(1, 1)
      local y    = line:sub(2, 2)
      local path = vim.trim(line:sub(4))
      local display = path:gsub(" -> ", " → ")
      if x ~= " " and x ~= "?" then
        local label = ({ M="modified", A="added", D="deleted", R="renamed", C="copied" })[x] or x
        table.insert(staged,   { path = path, display = display, label = label })
      end
      if y ~= " " and y ~= "?" then
        local label = ({ M="modified", D="deleted" })[y] or y
        table.insert(unstaged, { path = path, display = display, label = label })
      end
      if x == "?" and y == "?" then
        table.insert(unstaged, { path = path, display = display, label = "untracked" })
      end
    end
  end
  return staged, unstaged
end

-- ── Highlights ────────────────────────────────────────────────────────────────

local function setup_hls()
  vim.api.nvim_set_hl(0, "GitTabActive",   { bold = true,   fg = "#1a1b26", bg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "GitTabInactive", { fg = "#565f89", bg = "#1f2335" })
  vim.api.nvim_set_hl(0, "GitModalLabel",  { italic = true, fg = "#e0af68" })
  vim.api.nvim_set_hl(0, "GitModalPath",   { fg = "#c0caf5" })
  vim.api.nvim_set_hl(0, "GitModalHint",   { italic = true, fg = "#565f89" })
  vim.api.nvim_set_hl(0, "GitModalCursor", { bg = "#2a2e45", bold = true })
  vim.api.nvim_set_hl(0, "GitModalSel",    { fg = "#7aa2f7", bold = true })
  vim.api.nvim_set_hl(0, "GitModalEmpty",  { italic = true, fg = "#3b4261" })
  vim.api.nvim_set_hl(0, "GitDiffAdd",     { fg = "#9ece6a" })
  vim.api.nvim_set_hl(0, "GitDiffDel",     { fg = "#f7768e" })
  vim.api.nvim_set_hl(0, "GitDiffHunk",    { fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "GitDiffMeta",    { fg = "#bb9af7" })
end

-- ── Tab bar ───────────────────────────────────────────────────────────────────

-- Renders a two-element tab bar into tbuf. Returns highlight ranges for caller.
local function render_tabs(tbuf, tab, staged_count, unstaged_count)
  local t1 = string.format("  Staged (%d)  ", staged_count)
  local t2 = string.format("  Changes (%d)  ", unstaged_count)
  local line = t1 .. "│" .. t2
  vim.api.nvim_buf_set_option(tbuf, "modifiable", true)
  vim.api.nvim_buf_set_lines(tbuf, 0, -1, false, { line })
  vim.api.nvim_buf_clear_namespace(tbuf, -1, 0, -1)
  -- Highlight active/inactive tabs
  local active   = "GitTabActive"
  local inactive = "GitTabInactive"
  if tab == "staged" then
    vim.api.nvim_buf_add_highlight(tbuf, -1, active,   0, 0,        #t1)
    vim.api.nvim_buf_add_highlight(tbuf, -1, inactive, 0, #t1 + 1,  -1)
  else
    vim.api.nvim_buf_add_highlight(tbuf, -1, inactive, 0, 0,        #t1)
    vim.api.nvim_buf_add_highlight(tbuf, -1, active,   0, #t1 + 1,  -1)
  end
  vim.api.nvim_buf_set_option(tbuf, "modifiable", false)
end

-- ── List pane ─────────────────────────────────────────────────────────────────

-- Builds lines/hls/file_index for the active tab's file list.
-- file_index[row] = file entry (every row is a file — no blanks/headers).
local function build_file_list(files, selected, list_w)
  local lines, hls, file_index = {}, {}, {}

  if #files == 0 then
    table.insert(lines, "  (nothing here)")
    table.insert(hls, { line = 0, group = "GitModalEmpty", cs = 0, ce = -1 })
    table.insert(file_index, nil)
    return lines, hls, file_index
  end

  for _, f in ipairs(files) do
    local sel_marker = selected[f.path] and "● " or "  "
    local lbl        = string.format("%-10s", f.label)
    -- Truncate display path to fit list width
    local max_path   = list_w - #sel_marker - #lbl - 3
    local disp       = #f.display > max_path
      and ("…" .. f.display:sub(-(max_path - 1)))
      or  f.display
    local line = sel_marker .. lbl .. " " .. disp

    local row = #lines + 1
    table.insert(lines, line)
    -- sel marker
    if selected[f.path] then
      table.insert(hls, { line = row - 1, group = "GitModalSel",   cs = 0,                  ce = 2 })
    end
    table.insert(hls,   { line = row - 1, group = "GitModalLabel", cs = #sel_marker,        ce = #sel_marker + #lbl })
    table.insert(hls,   { line = row - 1, group = "GitModalPath",  cs = #sel_marker + #lbl + 1, ce = -1 })
    table.insert(file_index, f)
  end

  return lines, hls, file_index
end

-- ── Diff pane ─────────────────────────────────────────────────────────────────

local function build_diff(file, is_staged)
  if not file then
    return { "  Select a file to preview its diff." }, {}
  end

  local diff_raw
  if file.label == "untracked" then
    local content  = vim.fn.system("cat " .. vim.fn.shellescape(file.path))
    local out = { "  (untracked — full file)", "" }
    for _, l in ipairs(vim.split(content, "\n")) do
      table.insert(out, "+ " .. l)
    end
    diff_raw = table.concat(out, "\n")
  elseif is_staged then
    diff_raw = git("diff --staged -- " .. vim.fn.shellescape(file.path))
  else
    diff_raw = git("diff -- " .. vim.fn.shellescape(file.path))
  end

  if not diff_raw or diff_raw == "" then
    return { "  (no diff available)" }, {}
  end

  local lines = vim.split(diff_raw, "\n")
  local hls   = {}
  for i, l in ipairs(lines) do
    local r  = i - 1
    local ch = l:sub(1, 1)
    if     ch == "+"                       then table.insert(hls, { line = r, group = "GitDiffAdd",  cs = 0, ce = -1 })
    elseif ch == "-"                       then table.insert(hls, { line = r, group = "GitDiffDel",  cs = 0, ce = -1 })
    elseif ch == "@"                       then table.insert(hls, { line = r, group = "GitDiffHunk", cs = 0, ce = -1 })
    elseif l:match("^diff ") or l:match("^index ") or l:match("^[-+][-+][-+] ") then
      table.insert(hls, { line = r, group = "GitDiffMeta", cs = 0, ce = -1 })
    end
  end
  return lines, hls
end

-- ── Open modal ────────────────────────────────────────────────────────────────

function M.open()
  if not git("rev-parse --is-inside-work-tree 2>/dev/null"):find("true") then
    vim.notify("Not inside a git repository", vim.log.levels.WARN)
    return
  end

  setup_hls()

  local total_w = math.min(vim.o.columns - 6, 180)
  local height  = math.min(vim.o.lines - 8, 40)
  local list_w  = math.min(52, math.floor(total_w * 0.35))
  local prev_w  = total_w - list_w - 3
  local win_row = math.floor((vim.o.lines   - height - 3) / 2)
  local win_col = math.floor((vim.o.columns - total_w)    / 2)

  -- ── Tab bar buffer / window (1 row tall, above list) ─────────────────────

  local tbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(tbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(tbuf, "buftype",   "nofile")

  local twin = vim.api.nvim_open_win(tbuf, false, {
    relative  = "editor",
    row = win_row, col = win_col,
    width = list_w, height = 1,
    style     = "minimal",
    border    = "rounded",
    zindex    = 51,
  })

  -- ── List buffer / window ──────────────────────────────────────────────────

  local lbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(lbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(lbuf, "buftype",   "nofile")

  local lwin = vim.api.nvim_open_win(lbuf, true, {
    relative  = "editor",
    row = win_row + 3, col = win_col,
    width = list_w, height = height,
    style     = "minimal",
    border    = "rounded",
    title     = " Source Control ",
    title_pos = "center",
    zindex    = 50,
  })
  vim.api.nvim_win_set_option(lwin, "cursorline",  true)
  vim.api.nvim_win_set_option(lwin, "wrap",         false)
  vim.api.nvim_win_set_option(lwin, "winhighlight", "CursorLine:GitModalCursor")

  -- ── Preview buffer / window ───────────────────────────────────────────────

  local pbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(pbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(pbuf, "buftype",   "nofile")

  local pwin = vim.api.nvim_open_win(pbuf, false, {
    relative  = "editor",
    row = win_row, col = win_col + list_w + 2,
    width = prev_w, height = height + 3,
    style     = "minimal",
    border    = "rounded",
    title     = " Diff Preview ",
    title_pos = "center",
    zindex    = 50,
  })
  vim.api.nvim_win_set_option(pwin, "wrap",   false)
  vim.api.nvim_win_set_option(pwin, "number", false)

  -- ── State ─────────────────────────────────────────────────────────────────

  local tab      = "staged"   -- "staged" | "unstaged"
  local selected = {}         -- set of file.path strings
  local staged, unstaged
  local file_index            -- file_index[row] = file or nil

  -- ── Rendering ─────────────────────────────────────────────────────────────

  local function current_files()
    return tab == "staged" and staged or unstaged
  end

  local function render_preview(file)
    if not vim.api.nvim_buf_is_valid(pbuf) then return end
    local plines, phls = build_diff(file, tab == "staged")
    vim.api.nvim_buf_set_option(pbuf, "modifiable", true)
    vim.api.nvim_buf_clear_namespace(pbuf, -1, 0, -1)
    vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, plines)
    for _, h in ipairs(phls) do
      pcall(vim.api.nvim_buf_add_highlight, pbuf, -1, h.group, h.line, h.cs, h.ce)
    end
    vim.api.nvim_buf_set_option(pbuf, "modifiable", false)
    local title = file
      and string.format(" %s (%s) ", file.display:match("([^/]+)$") or file.display, tab)
      or  " Diff Preview "
    pcall(vim.api.nvim_win_set_config, pwin, { title = title, title_pos = "center" })
  end

  local function render_list(keep_row)
    local prev_row = keep_row
      or (vim.api.nvim_win_is_valid(lwin) and vim.api.nvim_win_get_cursor(lwin)[1] or 1)

    local files = current_files() or {}
    local lines, hls
    lines, hls, file_index = build_file_list(files, selected, list_w)

    vim.api.nvim_buf_set_option(lbuf, "modifiable", true)
    vim.api.nvim_buf_clear_namespace(lbuf, -1, 0, -1)
    vim.api.nvim_buf_set_lines(lbuf, 0, -1, false, lines)
    for _, h in ipairs(hls) do
      pcall(vim.api.nvim_buf_add_highlight, lbuf, -1, h.group, h.line, h.cs, h.ce)
    end
    vim.api.nvim_buf_set_option(lbuf, "modifiable", false)

    -- Place cursor on nearest valid row
    local target = nil
    for i = prev_row, #file_index do
      if file_index[i] then target = i break end
    end
    if not target then
      for i = math.min(prev_row, #file_index), 1, -1 do
        if file_index[i] then target = i break end
      end
    end
    if target and vim.api.nvim_win_is_valid(lwin) then
      vim.api.nvim_win_set_cursor(lwin, { target, 0 })
      render_preview(file_index[target])
    else
      render_preview(nil)
    end
  end

  local function refresh(keep_row)
    staged, unstaged = get_status()
    selected = {}  -- clear selection on refresh
    render_tabs(tbuf, tab, #staged, #unstaged)
    render_list(keep_row)
  end

  -- ── Navigation ─────────────────────────────────────────────────────────────

  local function file_at_cursor()
    if not vim.api.nvim_win_is_valid(lwin) or not file_index then return nil end
    local r = vim.api.nvim_win_get_cursor(lwin)[1]
    return file_index[r]
  end

  local function move(delta)
    if not vim.api.nvim_win_is_valid(lwin) or not file_index then return end
    local cur  = vim.api.nvim_win_get_cursor(lwin)[1]
    local step = delta > 0 and 1 or -1
    local new  = cur + step
    while new >= 1 and new <= #file_index do
      if file_index[new] then
        vim.api.nvim_win_set_cursor(lwin, { new, 0 })
        render_preview(file_index[new])
        return
      end
      new = new + step
    end
  end

  -- ── Actions ────────────────────────────────────────────────────────────────

  local function close()
    for _, w in ipairs({ twin, lwin, pwin }) do
      if vim.api.nvim_win_is_valid(w) then vim.api.nvim_win_close(w, true) end
    end
  end

  local function toggle_select()
    local f = file_at_cursor()
    if not f then return end
    if selected[f.path] then
      selected[f.path] = nil
    else
      selected[f.path] = true
    end
    local cur = vim.api.nvim_win_get_cursor(lwin)[1]
    render_list(cur)
    -- Restore cursor after re-render (render_list may move it to nearest valid)
    if vim.api.nvim_win_is_valid(lwin) then
      vim.api.nvim_win_set_cursor(lwin, { cur, 0 })
    end
  end

  local function targets_for_action()
    -- Returns list of files to act on: selected set, or cursor file if none selected
    local files = {}
    for _, f in ipairs(current_files() or {}) do
      if selected[f.path] then table.insert(files, f) end
    end
    if #files == 0 then
      local f = file_at_cursor()
      if f then files = { f } end
    end
    return files
  end

  local function stage()
    if tab ~= "unstaged" then return end
    local files = targets_for_action()
    if #files == 0 then return end
    for _, f in ipairs(files) do
      git_ok("add -- " .. vim.fn.shellescape(f.path))
    end
    refresh()
  end

  local function unstage()
    if tab ~= "staged" then return end
    local files = targets_for_action()
    if #files == 0 then return end
    for _, f in ipairs(files) do
      git_ok("restore --staged -- " .. vim.fn.shellescape(f.path))
    end
    refresh()
  end

  local function open_full_diff()
    local f = file_at_cursor()
    if not f then return end
    local is_staged = tab == "staged"
    close()
    local ok = is_staged
      and pcall(vim.cmd, "Gdiffsplit HEAD -- " .. f.path)
      or  pcall(vim.cmd, "Gdiffsplit -- " .. f.path)
    if not ok then
      local diff_out = is_staged
        and git("diff --staged -- " .. vim.fn.shellescape(f.path))
        or  git("diff -- "          .. vim.fn.shellescape(f.path))
      local dbuf = vim.api.nvim_create_buf(true, true)
      vim.api.nvim_buf_set_lines(dbuf, 0, -1, false, vim.split(diff_out, "\n"))
      vim.api.nvim_buf_set_option(dbuf, "filetype",   "diff")
      vim.api.nvim_buf_set_option(dbuf, "modifiable", false)
      vim.api.nvim_set_current_buf(dbuf)
    end
  end

  local function do_commit()
    staged, unstaged = get_status()
    if #staged == 0 then
      vim.notify("Nothing staged to commit", vim.log.levels.WARN)
      return
    end
    close()
    vim.ui.input({ prompt = "Commit message: " }, function(msg)
      if not msg or vim.trim(msg) == "" then
        vim.notify("Commit aborted (empty message)", vim.log.levels.WARN)
        return
      end
      local out = git("commit -m " .. vim.fn.shellescape(msg))
      if vim.v.shell_error ~= 0 then
        vim.notify("git commit failed:\n" .. out, vim.log.levels.ERROR)
      else
        vim.notify("Committed: " .. msg, vim.log.levels.INFO)
      end
    end)
  end

  local function switch_tab(t)
    tab      = t
    selected = {}
    staged, unstaged = get_status()
    render_tabs(tbuf, tab, #staged, #unstaged)
    render_list(1)
  end

  -- ── Tooltip (keybind cheatsheet) ───────────────────────────────────────────

  local function show_tooltip()
    local lines = {
      "  Keybindings                    ",
      "  ─────────────────────────────  ",
      "  j / k       navigate           ",
      "  <Tab>       switch tab         ",
      "  <Space>     toggle select      ",
      "  s           stage file(s)      ",
      "  u           unstage file(s)    ",
      "  A           stage all          ",
      "  U           unstage all        ",
      "  cc          commit             ",
      "  <CR> / dd   open full diff     ",
      "  r           refresh            ",
      "  q / <Esc>   close              ",
      "  ?           toggle this help   ",
      "                                 ",
      "  any key to dismiss             ",
    }

    local tt_w = 35
    local tt_h = #lines
    -- Anchor just to the right of the list window, vertically centred on it
    local lwin_cfg = vim.api.nvim_win_get_config(lwin)
    local base_row = type(lwin_cfg.row) == "table" and lwin_cfg.row[false] or lwin_cfg.row
    local base_col = type(lwin_cfg.col) == "table" and lwin_cfg.col[false] or lwin_cfg.col
    local tt_row   = base_row + math.floor((height - tt_h) / 2)
    local tt_col   = base_col + list_w + 4

    -- Keep within screen bounds
    tt_row = math.max(0, math.min(tt_row, vim.o.lines  - tt_h - 4))
    tt_col = math.max(0, math.min(tt_col, vim.o.columns - tt_w - 4))

    local ttbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(ttbuf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(ttbuf, "buftype",   "nofile")
    vim.api.nvim_buf_set_lines(ttbuf, 0, -1, false, lines)

    -- Highlights
    vim.api.nvim_set_hl(0, "GitTooltipBorder", { fg = "#7aa2f7" })
    vim.api.nvim_set_hl(0, "GitTooltipTitle",  { bold = true, fg = "#7aa2f7" })
    vim.api.nvim_set_hl(0, "GitTooltipKey",    { bold = true, fg = "#e0af68" })
    vim.api.nvim_set_hl(0, "GitTooltipDesc",   { fg = "#a9b1d6" })
    vim.api.nvim_set_hl(0, "GitTooltipDim",    { italic = true, fg = "#565f89" })

    -- Title + separator rows
    vim.api.nvim_buf_add_highlight(ttbuf, -1, "GitTooltipTitle", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(ttbuf, -1, "GitTooltipDim",   1, 0, -1)
    -- Key / description columns for each binding row
    for i = 2, #lines - 2 do
      local l = lines[i + 1]
      if l and l:find("  .-  ") then
        local key_end = (l:find("%s%s", 3) or 3) - 1
        vim.api.nvim_buf_add_highlight(ttbuf, -1, "GitTooltipKey",  i, 2, key_end)
        vim.api.nvim_buf_add_highlight(ttbuf, -1, "GitTooltipDesc", i, key_end, -1)
      end
    end
    vim.api.nvim_buf_add_highlight(ttbuf, -1, "GitTooltipDim", #lines - 1, 0, -1)
    vim.api.nvim_buf_set_option(ttbuf, "modifiable", false)

    local ttwin = vim.api.nvim_open_win(ttbuf, false, {
      relative  = "editor",
      row       = tt_row,
      col       = tt_col,
      width     = tt_w,
      height    = tt_h,
      style     = "minimal",
      border    = "rounded",
      title     = " Help ",
      title_pos = "center",
      zindex    = 60,
    })
    vim.api.nvim_win_set_option(ttwin, "winhighlight", "FloatBorder:GitTooltipBorder")

    -- Any keypress in the list window closes the tooltip
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = lbuf,
      once   = true,
      callback = function()
        if vim.api.nvim_win_is_valid(ttwin) then
          vim.api.nvim_win_close(ttwin, true)
        end
      end,
    })
    -- Also close when the main windows close
    vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
      buffer = lbuf,
      once   = true,
      callback = function()
        if vim.api.nvim_win_is_valid(ttwin) then
          vim.api.nvim_win_close(ttwin, true)
        end
      end,
    })
    -- ? again closes it immediately
    vim.keymap.set("n", "?", function()
      if vim.api.nvim_win_is_valid(ttwin) then
        vim.api.nvim_win_close(ttwin, true)
      end
      -- restore the normal ? binding after close
      vim.keymap.set("n", "?", show_tooltip, opts)
    end, { buffer = lbuf, noremap = true, silent = true })
  end

  -- ── Bootstrap ──────────────────────────────────────────────────────────────

  refresh(1)

  -- ── CursorMoved: snap off empty rows + keep preview in sync ───────────────

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = lbuf,
    callback = function()
      if not file_index then return end
      local cur = vim.api.nvim_win_get_cursor(lwin)[1]
      if file_index[cur] then
        render_preview(file_index[cur])
        return
      end
      -- Snap to nearest file row
      local target = nil
      for i = cur + 1, #file_index do
        if file_index[i] then target = i break end
      end
      if not target then
        for i = cur - 1, 1, -1 do
          if file_index[i] then target = i break end
        end
      end
      if target then
        vim.api.nvim_win_set_cursor(lwin, { target, 0 })
        render_preview(file_index[target])
      end
    end,
  })

  -- Tear everything down when any of the three windows closes
  local function on_close()
    for _, w in ipairs({ twin, lwin, pwin }) do
      pcall(vim.api.nvim_win_close, w, true)
    end
  end
  for _, buf in ipairs({ tbuf, lbuf }) do
    vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
      buffer = buf, once = true, callback = on_close,
    })
  end

  -- ── Keymaps ────────────────────────────────────────────────────────────────

  local opts = { buffer = lbuf, noremap = true, silent = true }

  vim.keymap.set("n", "j",      function() move(1) end,  opts)
  vim.keymap.set("n", "k",      function() move(-1) end, opts)
  vim.keymap.set("n", "<Down>", function() move(1) end,  opts)
  vim.keymap.set("n", "<Up>",   function() move(-1) end, opts)

  vim.keymap.set("n", "<Tab>", function()
    switch_tab(tab == "staged" and "unstaged" or "staged")
  end, opts)

  vim.keymap.set("n", "<Space>", toggle_select, opts)

  vim.keymap.set("n", "s", stage,   opts)
  vim.keymap.set("n", "u", unstage, opts)

  vim.keymap.set("n", "A", function()
    git_ok("add -A")
    switch_tab("staged")
  end, opts)

  vim.keymap.set("n", "U", function()
    git_ok("restore --staged .")
    switch_tab("unstaged")
  end, opts)

  vim.keymap.set("n", "<CR>", open_full_diff, opts)
  vim.keymap.set("n", "dd",   open_full_diff, opts)

  vim.keymap.set("n", "cc", do_commit, opts)
  vim.keymap.set("n", "r",  function() refresh() end, opts)
  vim.keymap.set("n", "?",     show_tooltip, opts)
  vim.keymap.set("n", "q",     close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

return M
