-- Onboarding: shown on first launch (or when force=true / <leader>?).
-- State is persisted in stdpath("data")/teavim_onboarding.json.
-- Users can skip permanently or re-run at any time.

local M = {}

local state_path = vim.fn.stdpath("data") .. "/teavim_onboarding.json"

local function load_state()
  local f = io.open(state_path, "r")
  if not f then return {} end
  local raw = f:read("*a")
  f:close()
  return vim.fn.json_decode(raw) or {}
end

local function save_state(state)
  local f = io.open(state_path, "w")
  if f then
    f:write(vim.fn.json_encode(state))
    f:close()
  end
end

-- ── ASCII art ─────────────────────────────────────────────────────────────────

local TEA_ART = {
  "        ) ) )      ",
  "      ( ( (        ",
  "    .__________.   ",
  "    |          |)  ",
  "    |   tea    |   ",
  "    |__________|   ",
  "     \\________/    ",
}

-- ── Page definitions (profile-aware) ─────────────────────────────────────────

local function pages()
  local profile = TeaVim.profile
  local feat    = TeaVim.features

  local p = {}

  -- Page 1: Welcome
  local welcome_lines = { "" }
  for _, l in ipairs(TEA_ART) do
    table.insert(welcome_lines, "                  " .. l)
  end
  vim.list_extend(welcome_lines, {
    "",
    "  TeaVim is a Neovim distribution built for everyone —",
    "  whether you live and breathe Vim motions or you're",
    "  coming straight from VSCode.",
    "",
    "  Your active profile:  " .. profile,
    "",
    "  This walkthrough covers the essentials.",
    "  Press  n / →  or  Enter  to go forward.",
    "  Press  p / ←  to go back.",
    "  Press  s  to skip and never show this again.",
    "  Press  q  to quit and see it again next time.",
    "",
  })
  table.insert(p, { title = "Welcome to TeaVim", lines = welcome_lines })

  -- Page 2: Profile explanation
  if profile == "vim" then
    table.insert(p, {
      title = "Profile: Vim",
      lines = {
        "",
        "  You are using the pure Vim profile.",
        "",
        "  Modes:",
        "    Normal    — navigate and run commands",
        "    Insert    — type text  (press i / a / o to enter)",
        "    Visual    — select text  (press v / V / <C-v>)",
        "    Command   — run Ex commands  (press :)",
        "",
        "  Key motions:",
        "    h j k l   — left / down / up / right",
        "    w b e     — word forward / back / end",
        "    gg G      — file start / end",
        "    / ?       — search forward / backward",
        "",
        "  To switch profile, edit  lua/user/config.lua  → profile",
        "",
      },
    })
  elseif profile == "vscode" then
    table.insert(p, {
      title = "Profile: VSCode",
      lines = {
        "",
        "  You are using the VSCode hybrid profile.",
        "",
        "  Vim modes still exist, AND your VSCode shortcuts work:",
        "",
        "    Ctrl+P         — find files",
        "    Ctrl+Shift+F   — search in project",
        "    Ctrl+Shift+P   — command palette",
        "    Ctrl+S         — save",
        "    Ctrl+B         — toggle file explorer",
        "    Ctrl+`         — toggle terminal",
        "    Ctrl+.         — code actions / quick fix",
        "    F2             — rename symbol",
        "    F12            — go to definition",
        "",
        "  You can still use Vim motions in Normal mode.",
        "",
      },
    })
  else -- vscode_pure
    table.insert(p, {
      title = "Profile: VSCode Pure",
      lines = {
        "",
        "  You are using the VSCode Pure profile.",
        "",
        "  All your VSCode shortcuts work out of the box:",
        "",
        "    Ctrl+P         — find files",
        "    Ctrl+Shift+F   — search in project",
        "    Ctrl+Shift+P   — command palette",
        "    Ctrl+S         — save",
        "    Ctrl+B         — toggle file explorer",
        "    Ctrl+`         — toggle terminal",
        "    Ctrl+Z / Y     — undo / redo",
        "    Ctrl+C / X / V — copy / cut / paste",
        "    ?              — show all shortcuts",
        "",
        "  Press i to enter Insert mode, Escape to return to Normal.",
        "  Arrow keys, Home, End, Page Up/Down all work normally.",
        "",
      },
    })
  end

  -- Page 3: Shortcuts panel
  table.insert(p, {
    title = "Shortcuts Panel (which-key)",
    lines = {
      "",
      "  Press  <Space>  in Normal mode to open the shortcuts panel.",
      profile == "vscode_pure" and
        "  Press  ?  from anywhere to open the shortcuts panel." or "",
      "",
      "  The panel groups every bound key by category:",
      "    <Space> f  — Find / fuzzy",
      "    <Space> e  — Explorer",
      "    <Space> t  — Terminal",
      "    <Space> l  — LSP / language tools",
      "    <Space> g  — Git",
      "    <Space> b  — Buffers",
      "    <Space> u  — UI toggles",
      "",
      "  You never need to memorise shortcuts —",
      "  just press Space and follow the prompts.",
      "",
    },
  })

  -- Page 4: Active features
  local active = {}
  if feat.explorer then table.insert(active, "  ✓  File Explorer   (neo-tree)   — Ctrl+B  or <Space>e") end
  if feat.fuzzy    then table.insert(active, "  ✓  Fuzzy Find      (telescope)  — Ctrl+P  or <Space>ff") end
  if feat.terminal then table.insert(active, "  ✓  Terminal        (toggleterm) — Ctrl+`  or <Space>tt") end
  if feat.lsp      then table.insert(active, "  ✓  LSP + Completion (blink.cmp) — auto, F2 / F12 / Ctrl+.") end

  if #active > 0 then
    local feat_lines = { "", "  Your enabled features:", "" }
    vim.list_extend(feat_lines, active)
    vim.list_extend(feat_lines, {
      "",
      "  To toggle a feature open  lua/user/config.lua",
      "  and set the key in  features = { ... }  to true/false.",
      "  Disabled features add zero startup cost.",
      "",
    })
    table.insert(p, { title = "Active Features", lines = feat_lines })
  end

  -- Page 5: Overrides
  table.insert(p, {
    title = "Customising TeaVim",
    lines = {
      "",
      "  All user overrides live in the  lua/user/  directory.",
      "  These files are never touched by TeaVim updates.",
      "",
      "  lua/user/config.lua   — override profile, features, leader",
      "  lua/user/plugins.lua  — add extra lazy.nvim plugin specs",
      "  lua/user/keymaps.lua  — add or remap any keybinding",
      "",
      "  Example lua/user/config.lua:",
      "    return { profile = 'vim', features = { terminal = false } }",
      "",
      "  Re-run this walkthrough any time with  <Space>?",
      "",
    },
  })

  -- Page 6: Done
  table.insert(p, {
    title = "You're all set!",
    lines = {
      "",
      "  That's everything you need to get started.",
      "",
      "  Quick reference:",
      "    <Space>     — open shortcuts panel",
      "    <Space>?    — re-open this walkthrough",
      "    <Space>L    — open Lazy plugin manager",
      "    <Space>U    — update TeaVim",
      "    <Space>lm   — open Mason (install language servers)",
      "",
      "  Happy coding!  ☕",
      "",
      "  Press  Enter  or  q  to close.",
      "",
    },
  })

  return p
end

-- ── Rendering ─────────────────────────────────────────────────────────────────

local function render(buf, page_data, current, total)
  local width  = 64
  local border = "─"

  local function centre(str)
    local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(str)) / 2))
    return string.rep(" ", pad) .. str
  end

  local lines = {}
  table.insert(lines, "")
  table.insert(lines, centre("☕ TeaVim  —  " .. page_data.title))
  table.insert(lines, "  " .. string.rep(border, width - 4))
  table.insert(lines, "")

  for _, l in ipairs(page_data.lines) do
    table.insert(lines, l)
  end

  table.insert(lines, "  " .. string.rep(border, width - 4))
  table.insert(lines, centre(string.format("[ %d / %d ]   n → next   p ← prev   s skip   q quit", current, total)))
  table.insert(lines, "")

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- ── Public API ────────────────────────────────────────────────────────────────

function M.start(force)
  local cfg = TeaVim.onboarding
  if cfg == false then return end

  local state = load_state()
  if state.skipped and not force then return end

  local all_pages = pages()
  local current   = 1
  local total     = #all_pages

  -- Create floating window
  local width  = 68
  local height = 26
  local row    = math.floor((vim.o.lines   - height) / 2)
  local col    = math.floor((vim.o.columns - width)  / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype",   "nofile")

  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = row,
    col       = col,
    style     = "minimal",
    border    = "rounded",
    title     = " TeaVim Onboarding ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "wrap",       true)
  vim.api.nvim_win_set_option(win, "cursorline",  false)

  -- Always open in Normal mode regardless of profile.
  vim.cmd("stopinsert")

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function go(delta)
    current = math.max(1, math.min(total, current + delta))
    render(buf, all_pages[current], current, total)
    -- Stay in Normal mode after re-render.
    vim.cmd("stopinsert")
  end

  render(buf, all_pages[current], current, total)

  local opts = { buffer = buf, silent = true, noremap = true }

  vim.keymap.set("n", "n",       function() go(1)  end, opts)
  vim.keymap.set("n", "<Right>",  function() go(1)  end, opts)
  vim.keymap.set("n", "<CR>",     function()
    if current == total then close() else go(1) end
  end, opts)
  vim.keymap.set("n", "p",       function() go(-1) end, opts)
  vim.keymap.set("n", "<Left>",   function() go(-1) end, opts)

  vim.keymap.set("n", "s", function()
    save_state({ skipped = true })
    close()
    vim.notify("TeaVim: onboarding skipped. Press <Space>? to re-open.", vim.log.levels.INFO)
  end, opts)

  vim.keymap.set("n", "q",     close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  -- Prevent any insert-mode trigger inside the onboarding buffer.
  vim.keymap.set("n", "i", "<Nop>", opts)
  vim.keymap.set("n", "a", "<Nop>", opts)
  vim.keymap.set("n", "o", "<Nop>", opts)

  -- Re-assert Normal mode if something sneaks us into insert.
  vim.api.nvim_create_autocmd("InsertEnter", {
    buffer   = buf,
    callback = function() vim.cmd("stopinsert") end,
  })

  -- Mark as seen (but not skipped) so it doesn't auto-open next time.
  save_state({ skipped = false, seen = true })
end

-- Auto-open on startup if not yet seen/skipped.
vim.api.nvim_create_autocmd("VimEnter", {
  once     = true,
  callback = function()
    -- Defer so plugins finish loading and the UI is ready.
    vim.defer_fn(function() M.start(false) end, 100)
  end,
})

return M
