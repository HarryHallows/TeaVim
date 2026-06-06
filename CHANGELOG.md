# TeaVim Changelog

## [0.4.0] - 2026-06-06

### Added
- Keymap cheatsheet (`<leader>K`) — flat, grouped, feature-flag-aware reference in a floating window with syntax highlighting and in-float search
- WSL2 install fix: `remote-install.sh` re-attaches stdin to `/dev/tty` so interactive prompts work when piped from curl
- Non-interactive fallback in `install.sh` — all prompts default gracefully when no TTY is present (auto-backup, symlink, `vscode` profile)
- README WSL2 callout and manual install recommended for WSL2 users

---

## [0.3.0] - 2026-06-03

### Added
- Telescope-routed LSP navigation: `gd`, `gr`, `gi`, `gy` open results in Telescope pickers instead of the quickfix list
- Project-wide find & replace via Spectre (`<leader>sr`, `<leader>sw`, `<leader>sf`)
- Ctrl+click go-to-definition across all profiles
- Debug feature: `nvim-dap` + `nvim-dap-ui` with step-through debugging, inline breakpoints, and adapters for Python, JS/TS, Go, Rust, C, C++ installed via Mason (`<leader>d*`, F5/F10/F11)

### Fixed
- Dashboard now shows correctly after first-install lazy.nvim plugin UI completes

---

## [0.2.0] - 2026-06-02

### Added
- Update command (`:TeaVimUpdate`) with changelog viewer
- `<Space>U` keymap to pull updates from anywhere
- Onboarding reset command (`:TeaVimReset`)
- Source control modal (`<leader>gs`) and terminal manager UI (`<leader>tm`, `Ctrl+\`)
- Git modal and terminal manager wired across all profiles
- Terminal Manager and Git Source Control entries in command palette
- Multi-terminal support with cycle and close keymaps
- `gf` keymap in terminal buffers to open `file:line` under cursor
- Command palette (`Ctrl+Shift+P`) with TeaVim actions and native commands
- Theme picker (`<leader>ut`) with live preview
- Alpha-nvim dashboard with teacup splash screen
- `LspRestart` exposed via palette and `<leader>lR`
- Auto-detect Python venv for pyright LSP server
- Stash local changes before update pull, restore after
- `user/config.lua` reset to clean commented-out template

### Fixed
- Neo-tree no longer auto-opens on startup with a scratch buffer
- Quit blocked by unnamed buffer resolved via `hijack_netrw_behavior = "disabled"`
- Buffer close now switches buffer before deleting so the window stays open
- which-key groups not showing feature-gated keymaps
- Command palette list reordering while navigating fixed
- Treesitter and dashboard config errors
- Treesitter config: use `main = "nvim-treesitter.config"` (not `.configs`)
- Disable treesitter in Telescope previewer to fix `ft_to_lang` errors

---

## [0.1.0] - 2026-06-02

### Added
- Initial release
- Three profiles: `vim`, `vscode`, `vscode_pure`
- Feature flags: explorer (neo-tree), fuzzy (Telescope), terminal (toggleterm), LSP (mason + blink.cmp)
- which-key shortcuts panel (`<Space>` to open)
- Onboarding walkthrough shown on first launch, skippable, re-runnable with `<Space>?`
- `install.sh` and `remote-install.sh` for curl-based install
