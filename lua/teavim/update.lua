-- TeaVim updater
-- Runs `git pull` on the repo, detects the new version, and shows the
-- relevant CHANGELOG section in a floating window.

local M = {}

local function repo_dir()
  -- Resolve the real path of this file back to the repo root.
  -- File lives at lua/teavim/update.lua, so :h:h:h walks to repo root.
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

-- ── Changelog parser ──────────────────────────────────────────────────────────
-- Returns a table of { version, date, lines[] } for every section in CHANGELOG.md.
local function parse_changelog(path)
  local f = io.open(path, "r")
  if not f then return {} end

  local sections = {}
  local current  = nil

  for line in f:lines() do
    local ver, date = line:match("^## %[(.-)%]%s*%-%s*(.+)$")
    if ver then
      if current then table.insert(sections, current) end
      current = { version = ver, date = date, lines = {} }
    elseif current then
      table.insert(current.lines, line)
    end
  end
  if current then table.insert(sections, current) end
  f:close()
  return sections
end

-- ── Floating window renderer ──────────────────────────────────────────────────
local function show_changelog(sections, updated_to)
  if #sections == 0 then
    vim.notify("TeaVim: no changelog found.", vim.log.levels.WARN)
    return
  end

  local width  = 70
  local height = 30
  local row    = math.floor((vim.o.lines   - height) / 2)
  local col    = math.floor((vim.o.columns - width)  / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype",  "markdown")

  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = row,
    col       = col,
    style     = "minimal",
    border    = "rounded",
    title     = updated_to
      and string.format(" ☕ TeaVim updated → v%s ", updated_to)
      or  " ☕ TeaVim Changelog ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "wrap",       true)
  vim.api.nvim_win_set_option(win, "cursorline",  true)

  -- Build lines: show the section matching updated_to first, then the rest.
  local output = {}
  local function add_section(s)
    table.insert(output, string.format("## [%s] — %s", s.version, s.date))
    table.insert(output, string.rep("─", width - 4))
    for _, l in ipairs(s.lines) do
      -- strip blank lines at the very start/end of a section
      if l ~= "---" then table.insert(output, l) end
    end
    table.insert(output, "")
  end

  local rest = {}
  for _, s in ipairs(sections) do
    if updated_to and s.version == updated_to then
      add_section(s)
    else
      table.insert(rest, s)
    end
  end
  for _, s in ipairs(rest) do add_section(s) end

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Move cursor to top
  vim.api.nvim_win_set_cursor(win, { 1, 0 })

  local opts = { buffer = buf, silent = true, noremap = true }
  vim.keymap.set("n", "q",     function() vim.api.nvim_win_close(win, true) end, opts)
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, opts)
end

-- ── Git helpers ───────────────────────────────────────────────────────────────
local function git(args, cwd, on_exit)
  local stdout = {}
  local stderr = {}
  vim.fn.jobstart(vim.list_extend({ "git" }, args), {
    cwd       = cwd,
    on_stdout = function(_, data) vim.list_extend(stdout, data) end,
    on_stderr = function(_, data) vim.list_extend(stderr, data) end,
    on_exit   = function(_, code) on_exit(code, stdout, stderr) end,
  })
end

local function current_version(cwd, cb)
  -- Try to read version from latest git tag; fall back to short SHA.
  git({ "describe", "--tags", "--abbrev=0" }, cwd, function(code, out)
    if code == 0 and out[1] and out[1] ~= "" then
      cb(out[1]:gsub("^v", ""):gsub("%s+", ""))
    else
      git({ "rev-parse", "--short", "HEAD" }, cwd, function(_, sha)
        cb((sha[1] or "unknown"):gsub("%s+", ""))
      end)
    end
  end)
end

-- ── Public: run update ────────────────────────────────────────────────────────
function M.run()
  local dir = repo_dir()

  vim.notify("TeaVim: checking for updates…", vim.log.levels.INFO)

  -- Capture the version before pulling.
  current_version(dir, function(before)
    git({ "pull", "--ff-only" }, dir, function(code, out, err)
      if code ~= 0 then
        local msg = table.concat(err, "\n"):gsub("%s+$", "")
        vim.schedule(function()
          vim.notify("TeaVim update failed:\n" .. msg, vim.log.levels.ERROR)
        end)
        return
      end

      local pull_output = table.concat(out, "\n")

      -- Already up to date — still offer to show changelog.
      if pull_output:find("Already up to date") then
        vim.schedule(function()
          vim.notify("TeaVim: already up to date (v" .. before .. ").", vim.log.levels.INFO)
          local changelog = parse_changelog(dir .. "/CHANGELOG.md")
          if #changelog > 0 then
            show_changelog(changelog, before)
          end
        end)
        return
      end

      -- Something was pulled — get the new version.
      current_version(dir, function(after)
        vim.schedule(function()
          vim.notify(
            string.format("TeaVim: updated v%s → v%s. Reload Neovim to apply.", before, after),
            vim.log.levels.INFO
          )
          local changelog = parse_changelog(dir .. "/CHANGELOG.md")
          show_changelog(changelog, after)
        end)
      end)
    end)
  end)
end

-- ── Commands & keymaps ────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("TeaVimUpdate",    M.run, { desc = "Update TeaVim and view changelog" })
vim.api.nvim_create_user_command("TeaVimChangelog", function()
  local dir       = repo_dir()
  local changelog = parse_changelog(dir .. "/CHANGELOG.md")
  current_version(dir, function(ver)
    vim.schedule(function() show_changelog(changelog, ver) end)
  end)
end, { desc = "View TeaVim changelog" })

vim.keymap.set("n", "<leader>U",  M.run, { desc = "Update TeaVim" })
vim.keymap.set("n", "<leader>uC", function()
  local dir       = repo_dir()
  local changelog = parse_changelog(dir .. "/CHANGELOG.md")
  current_version(dir, function(ver)
    vim.schedule(function() show_changelog(changelog, ver) end)
  end)
end, { desc = "View TeaVim changelog" })

return M
