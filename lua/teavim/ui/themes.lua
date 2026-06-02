-- Theme picker: split float with live preview.
-- j/k to navigate, Enter to confirm, Esc/q to revert.
-- "Add custom theme" prompts for a repo slug and variant, then persists to user/config.lua.

local M = {}

-- ── Built-in theme catalogue ──────────────────────────────────────────────────
-- Each entry: { label, colorscheme, plugin }
-- plugin is the lazy.nvim repo slug (already declared in plugins.lua as optional).
M.themes = {
  { label = "Tokyo Night Storm",  cs = "tokyonight-storm",   plugin = "folke/tokyonight.nvim" },
  { label = "Tokyo Night Night",  cs = "tokyonight-night",   plugin = "folke/tokyonight.nvim" },
  { label = "Tokyo Night Moon",   cs = "tokyonight-moon",    plugin = "folke/tokyonight.nvim" },
  { label = "Tokyo Night Day",    cs = "tokyonight-day",     plugin = "folke/tokyonight.nvim" },
  { label = "Catppuccin Mocha",   cs = "catppuccin-mocha",   plugin = "catppuccin/nvim" },
  { label = "Catppuccin Macchiato",cs= "catppuccin-macchiato",plugin = "catppuccin/nvim" },
  { label = "Catppuccin Frappé",  cs = "catppuccin-frappe",  plugin = "catppuccin/nvim" },
  { label = "Catppuccin Latte",   cs = "catppuccin-latte",   plugin = "catppuccin/nvim" },
  { label = "Gruvbox Dark",       cs = "gruvbox",            plugin = "ellisonleao/gruvbox.nvim" },
  { label = "Rose Pine",          cs = "rose-pine",          plugin = "rose-pine/neovim" },
  { label = "Rose Pine Moon",     cs = "rose-pine-moon",     plugin = "rose-pine/neovim" },
  { label = "Rose Pine Dawn",     cs = "rose-pine-dawn",     plugin = "rose-pine/neovim" },
  { label = "Kanagawa Wave",      cs = "kanagawa-wave",      plugin = "rebelot/kanagawa.nvim" },
  { label = "Kanagawa Dragon",    cs = "kanagawa-dragon",    plugin = "rebelot/kanagawa.nvim" },
  { label = "Kanagawa Lotus",     cs = "kanagawa-lotus",     plugin = "rebelot/kanagawa.nvim" },
  { label = "Nord",               cs = "nord",               plugin = "shaunsingh/nord.nvim" },
  { label = "Dracula",            cs = "dracula",            plugin = "Mofiqul/dracula.nvim" },
  { label = "One Dark Pro",       cs = "onedark",            plugin = "olimorris/onedarkpro.nvim" },
  { label = "+ Add custom theme", cs = "__custom__",         plugin = nil },
}

-- ── Persist chosen theme to user/config.lua ──────────────────────────────────
local function config_path()
  return vim.fn.stdpath("config") .. "/lua/user/config.lua"
end

local function save_theme(cs)
  local path = config_path()
  local f = io.open(path, "r")
  if not f then return end
  local src = f:read("*a")
  f:close()

  -- If a theme key already exists, replace it; otherwise inject before the closing brace.
  if src:find('theme%s*=') then
    src = src:gsub('theme%s*=%s*"[^"]*"', string.format('theme = "%s"', cs))
  else
    src = src:gsub('(return%s*{)', string.format('%%1\n  theme = "%s",', cs))
  end

  local w = io.open(path, "w")
  if w then w:write(src) w:close() end
end

local function add_custom_plugin_to_user(repo, cs)
  local path = config_path()
  local f = io.open(path, "r")
  if not f then return end
  local src = f:read("*a")
  f:close()

  -- Append to user/plugins.lua instead (cleaner separation).
  local plugins_path = vim.fn.stdpath("config") .. "/lua/user/plugins.lua"
  local pf = io.open(plugins_path, "r")
  local psrc = pf and pf:read("*a") or "return {}\n"
  if pf then pf:close() end

  local entry = string.format('  { "%s", lazy = false, priority = 1000 },\n', repo)
  if not psrc:find(repo, 1, true) then
    psrc = psrc:gsub("return%s*{", "return {\n" .. entry)
    local pw = io.open(plugins_path, "w")
    if pw then pw:write(psrc) pw:close() end
  end
end

-- ── Apply colorscheme safely ──────────────────────────────────────────────────
local function apply(cs)
  local ok, err = pcall(vim.cmd, "colorscheme " .. cs)
  if not ok then
    vim.notify("Theme not installed yet — run :Lazy install\n" .. err, vim.log.levels.WARN)
  end
end

-- ── Preview pane content ──────────────────────────────────────────────────────
local preview_lines = {
  "",
  "  -- preview.lua",
  "",
  '  local M = {}',
  "",
  "  function M.greet(name)",
  '    if name == nil then',
  '      name = "world"',
  "    end",
  '    print("Hello, " .. name .. "!")',
  "    return true",
  "  end",
  "",
  "  -- Keywords, strings, numbers",
  "  local x = 42",
  '  local s = "TeaVim"',
  "  local t = { x, s, true, nil }",
  "",
  "  return M",
  "",
}

-- ── Open picker ───────────────────────────────────────────────────────────────
function M.open()
  local original_cs = vim.g.colors_name or "default"
  local themes       = M.themes
  local cursor       = 1

  -- Dimensions
  local total_w  = math.min(vim.o.columns - 4, 90)
  local list_w   = 28
  local prev_w   = total_w - list_w - 3  -- 3 = border chars
  local height   = math.min(#themes + 2, vim.o.lines - 6)
  local row      = math.floor((vim.o.lines   - height) / 2)
  local col      = math.floor((vim.o.columns - total_w) / 2)

  -- List buffer + window
  local lbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(lbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(lbuf, "buftype",   "nofile")

  local lwin = vim.api.nvim_open_win(lbuf, true, {
    relative  = "editor",
    row       = row,
    col       = col,
    width     = list_w,
    height    = height,
    style     = "minimal",
    border    = "rounded",
    title     = " Themes ",
    title_pos = "center",
    zindex    = 50,
  })
  vim.api.nvim_win_set_option(lwin, "cursorline", true)
  vim.api.nvim_win_set_option(lwin, "wrap",       false)

  -- Preview buffer + window
  local pbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(pbuf, "bufhidden",  "wipe")
  vim.api.nvim_buf_set_option(pbuf, "buftype",    "nofile")
  vim.api.nvim_buf_set_option(pbuf, "filetype",   "lua")
  vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, preview_lines)
  vim.api.nvim_buf_set_option(pbuf, "modifiable", false)

  local pwin = vim.api.nvim_open_win(pbuf, false, {
    relative  = "editor",
    row       = row,
    col       = col + list_w + 2,
    width     = prev_w,
    height    = height,
    style     = "minimal",
    border    = "rounded",
    title     = " Preview ",
    title_pos = "center",
    zindex    = 50,
  })
  vim.api.nvim_win_set_option(pwin, "wrap", false)

  -- Populate list
  local function render_list()
    local lines = {}
    for i, t in ipairs(themes) do
      local prefix = (i == cursor) and "  " or "  "
      lines[i] = prefix .. t.label
    end
    vim.api.nvim_buf_set_option(lbuf, "modifiable", true)
    vim.api.nvim_buf_set_lines(lbuf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(lbuf, "modifiable", false)
    vim.api.nvim_win_set_cursor(lwin, { cursor, 0 })
  end

  local function preview_current()
    local t = themes[cursor]
    if t.cs ~= "__custom__" then
      apply(t.cs)
    end
  end

  local function close_wins()
    if vim.api.nvim_win_is_valid(lwin) then vim.api.nvim_win_close(lwin, true) end
    if vim.api.nvim_win_is_valid(pwin) then vim.api.nvim_win_close(pwin, true) end
  end

  local function confirm()
    local t = themes[cursor]
    if t.cs == "__custom__" then
      close_wins()
      vim.ui.input({ prompt = "Plugin repo (e.g. owner/repo.nvim): " }, function(repo)
        if not repo or repo == "" then return end
        vim.ui.input({ prompt = "Colorscheme name: " }, function(cs)
          if not cs or cs == "" then return end
          add_custom_plugin_to_user(repo, cs)
          save_theme(cs)
          vim.notify(
            string.format("Added %s. Run :Lazy install, then restart nvim.", repo),
            vim.log.levels.INFO
          )
        end)
      end)
    else
      save_theme(t.cs)
      close_wins()
      vim.notify("Theme set to: " .. t.label, vim.log.levels.INFO)
    end
  end

  local function revert()
    apply(original_cs)
    close_wins()
  end

  render_list()
  preview_current()

  local opts = { buffer = lbuf, noremap = true, silent = true }

  vim.keymap.set("n", "j", function()
    cursor = math.min(cursor + 1, #themes)
    render_list()
    preview_current()
  end, opts)

  vim.keymap.set("n", "k", function()
    cursor = math.max(cursor - 1, 1)
    render_list()
    preview_current()
  end, opts)

  vim.keymap.set("n", "<Down>", function()
    cursor = math.min(cursor + 1, #themes)
    render_list()
    preview_current()
  end, opts)

  vim.keymap.set("n", "<Up>", function()
    cursor = math.max(cursor - 1, 1)
    render_list()
    preview_current()
  end, opts)

  vim.keymap.set("n", "<CR>",  confirm, opts)
  vim.keymap.set("n", "q",     revert,  opts)
  vim.keymap.set("n", "<Esc>", revert,  opts)

  -- Position cursor on the current theme if it matches one in the list
  for i, t in ipairs(themes) do
    if t.cs == original_cs then
      cursor = i
      render_list()
      break
    end
  end
end

return M
