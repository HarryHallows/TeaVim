# TeaVim Changelog

## [0.2.0] - 2026-06-02

### Added
- Update command (`:TeaVimUpdate`) with changelog viewer
- `<Space>U` keymap to pull updates from anywhere
- Onboarding reset command (`:TeaVimReset`)

### Fixed
- Neo-tree no longer auto-opens on startup with a scratch buffer
- Quit blocked by unnamed buffer resolved via `hijack_netrw_behavior = "disabled"`

---

## [0.1.0] - 2026-06-02

### Added
- Initial release
- Three profiles: `vim`, `vscode`, `vscode_pure`
- Feature flags: explorer (neo-tree), fuzzy (telescope), terminal (toggleterm), LSP (mason + blink.cmp)
- which-key shortcuts panel (`<Space>` to open)
- Onboarding walkthrough shown on first launch, skippable, re-runnable with `<Space>?`
- `install.sh` and `remote-install.sh` for curl-based install
