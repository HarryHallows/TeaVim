-- TeaVim command palette — opened with Ctrl+Shift+P.
-- A Telescope picker that merges TeaVim actions with native nvim commands.

local M = {}

local pickers    = require("telescope.pickers")
local finders    = require("telescope.finders")
local conf       = require("telescope.config").values
local actions    = require("telescope.actions")
local state      = require("telescope.actions.state")

-- ── TeaVim actions ────────────────────────────────────────────────────────────
local function teavim_commands()
  local cmds = {
    { name = "TeaVim: Theme Picker",        action = function() require("teavim.ui.themes").open() end },
    { name = "TeaVim: Onboarding",          action = function() require("teavim.onboarding").start(true) end },
    { name = "TeaVim: Update",              action = function() require("teavim.update").run() end },
    { name = "TeaVim: Changelog",           action = function() vim.cmd("TeaVimChangelog") end },
    { name = "TeaVim: Open Lazy",           action = function() vim.cmd("Lazy") end },
    { name = "TeaVim: Toggle Line Numbers", action = function() vim.cmd("set number!") end },
    { name = "TeaVim: Toggle Relative Numbers", action = function() vim.cmd("set relativenumber!") end },
    { name = "TeaVim: Toggle Word Wrap",    action = function() vim.cmd("set wrap!") end },
  }

  if TeaVim.features.lsp then
    vim.list_extend(cmds, {
      { name = "LSP: Open Mason",      action = function() vim.cmd("Mason") end },
      { name = "LSP: Info",            action = function() vim.cmd("LspInfo") end },
      { name = "LSP: Format File",     action = function() vim.lsp.buf.format() end },
      { name = "LSP: Rename Symbol",   action = function() vim.lsp.buf.rename() end },
      { name = "LSP: Code Action",     action = function() vim.lsp.buf.code_action() end },
    })
  end

  if TeaVim.features.explorer then
    vim.list_extend(cmds, {
      { name = "Explorer: Toggle",         action = function() vim.cmd("Neotree toggle") end },
      { name = "Explorer: Reveal File",    action = function() vim.cmd("Neotree reveal") end },
      { name = "Explorer: Git Status",     action = function() vim.cmd("Neotree git_status") end },
    })
  end

  if TeaVim.features.terminal then
    vim.list_extend(cmds, {
      { name = "Terminal: Toggle Float",      action = function() vim.cmd("ToggleTerm direction=float") end },
      { name = "Terminal: Toggle Horizontal", action = function() vim.cmd("ToggleTerm direction=horizontal") end },
      { name = "Terminal: Toggle Vertical",   action = function() vim.cmd("ToggleTerm direction=vertical") end },
    })
  end

  if TeaVim.features.fuzzy then
    vim.list_extend(cmds, {
      { name = "Find: Files",            action = function() vim.cmd("Telescope find_files") end },
      { name = "Find: Live Grep",        action = function() vim.cmd("Telescope live_grep") end },
      { name = "Find: Recent Files",     action = function() vim.cmd("Telescope oldfiles") end },
      { name = "Find: Buffers",          action = function() vim.cmd("Telescope buffers") end },
      { name = "Find: Help Tags",        action = function() vim.cmd("Telescope help_tags") end },
      { name = "Find: Diagnostics",      action = function() vim.cmd("Telescope diagnostics") end },
    })
  end

  vim.list_extend(cmds, {
    { name = "Buffer: Delete",       action = function() vim.cmd("bdelete") end },
    { name = "Buffer: Next",         action = function() vim.cmd("bnext") end },
    { name = "Buffer: Previous",     action = function() vim.cmd("bprevious") end },
    { name = "File: Save",           action = function() vim.cmd("w") end },
    { name = "File: Save All",       action = function() vim.cmd("wa") end },
    { name = "File: New",            action = function() vim.cmd("enew") end },
    { name = "Window: Split Right",  action = function() vim.cmd("vsplit") end },
    { name = "Window: Split Below",  action = function() vim.cmd("split") end },
    { name = "Quit Neovim",          action = function() vim.cmd("qa") end },
  })

  return cmds
end

-- ── Open palette ──────────────────────────────────────────────────────────────
function M.open()
  -- Leave insert mode first so the picker opens cleanly.
  vim.cmd("stopinsert")

  local cmds = teavim_commands()

  pickers.new({}, {
    prompt_title = "  Command Palette",
    finder = finders.new_table({
      results = cmds,
      entry_maker = function(entry)
        return {
          value   = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = require("telescope.sorters").empty(),
    attach_mappings = function(buf, map)
      actions.select_default:replace(function()
        actions.close(buf)
        local sel = state.get_selected_entry()
        if sel then sel.value.action() end
      end)
      -- Also run on Tab so it feels natural
      map("i", "<Tab>", function()
        actions.close(buf)
        local sel = state.get_selected_entry()
        if sel then sel.value.action() end
      end)
      return true
    end,
  }):find()
end

return M
