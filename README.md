# ☕ TeaVim

A batteries-included Neovim distribution for people who want a great editor without spending days configuring one. Pick your editing style, get sensible defaults, and stay out of the way.

---

## Who is this for?

- **Coming from VSCode?** Use `vscode` or `vscode_pure` profile — your muscle memory still works.
- **Already know Vim?** Use the `vim` profile — pure motions, no compromises.
- **Just want something that works?** The defaults are production-ready out of the box.

---

## Profiles

| Profile | Description |
|---|---|
| `vscode` | Vim modes enabled with VSCode shortcuts layered on top (default) |
| `vscode_pure` | Modal-less — behaves like a normal text editor |
| `vim` | Pure Vim motions, no VSCode shortcuts |

Switch anytime by editing `~/.config/nvim/lua/user/config.lua`.

---

## Features

All features are opt-in via feature flags. Disabled features add **zero startup cost** — their plugins never load.

| Flag | Plugin | Description |
|---|---|---|
| `explorer` | neo-tree | File tree sidebar |
| `fuzzy` | Telescope | Fuzzy find files, text, and commands |
| `terminal` | toggleterm | Floating/split embedded terminal |
| `lsp` | lspconfig + Mason + blink.cmp | Language servers and completion |
| `debug` | nvim-dap + dap-ui | Inline breakpoints and step-through debugging |

Always included: statusline (lualine), dashboard (alpha), shortcuts panel (which-key), notifications (nvim-notify), indent guides, auto-pairs, comment toggling, git signs, Treesitter syntax highlighting.

**Built-in colorschemes:** Tokyo Night, Catppuccin, Gruvbox, Rose Pine, Kanagawa, Nord, Dracula, One Dark.

---

## Requirements

- Neovim **0.10.0+**
- git
- node + npm (for LSP servers)
- python3

---

## Install

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/HarryHallows/TeaVim/main/remote-install.sh | bash
```

This clones TeaVim to `~/.local/share/teavim`, symlinks it as your Neovim config, backs up any existing config, and sets your profile. On first launch, lazy.nvim installs all plugins automatically.

> **WSL2 / no-TTY note:** If the one-liner hangs or errors on the interactive prompts, use the manual steps below instead — they run the installer directly with a proper TTY.

### Manual (recommended for WSL2)

```bash
git clone --depth=1 https://github.com/HarryHallows/TeaVim.git ~/.local/share/teavim
bash ~/.local/share/teavim/install.sh
```

---

## Customisation

**The only file you need to touch:**

```
~/.config/nvim/lua/user/config.lua
```

```lua
return {
  profile  = "vscode",      -- "vim" | "vscode" | "vscode_pure"
  theme    = "tokyonight-night",
  leader   = " ",
  features = {
    explorer = true,
    fuzzy    = true,
    terminal = true,
    lsp      = true,
    debug    = true,
  },
}
```

**Add extra plugins** in `lua/user/plugins.lua` — same lazy.nvim spec format, merged at startup.

**Add extra keymaps** in `lua/user/keymaps.lua` — loaded last so they always win.

---

## Key bindings (quick reference)

`<Space>` opens which-key with a full searchable list of every binding. A few highlights:

| Key | Action |
|---|---|
| `<Space><Space>` | Find files |
| `<Space>e` | Toggle file explorer |
| `<Space>fg` | Live grep |
| `<C-\`` \>` | Open terminal |
| `<Space>gs` | Git source control |
| `<Space>?` | Re-run onboarding |
| `<Space>U` | Update TeaVim |

**Inside the terminal:**

| Key | Action |
|---|---|
| `<Esc><Esc>` | Exit terminal mode (normal mode) |
| `i` / `a` | Re-enter terminal mode |
| `<C-t>` | New terminal |
| `<C-]>` / `<C-[>` | Cycle next/prev terminal |
| `<C-x>` | Close terminal |

**Debugging** (requires `debug = true`):

The debug UI opens automatically when a session starts and closes when it ends. Adapters for Python, JS/TS, Go, Rust, C, and C++ are installed via Mason.

| Key | Action |
|---|---|
| `<F5>` | Start / Continue |
| `<Shift+F5>` | Stop |
| `<F9>` | Toggle breakpoint |
| `<Shift+F9>` | Conditional breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<Shift+F11>` | Step out |
| `<C-S-d>` | Toggle debug panel (vscode profile) |
| `<Space>db` | Toggle breakpoint |
| `<Space>dB` | Conditional breakpoint |
| `<Space>dl` | Log point |
| `<Space>dL` | Clear all breakpoints |
| `<Space>du` | Toggle debug UI |
| `<Space>de` | Evaluate expression / selection |
| `<Space>dr` | Open REPL |
| `<Space>dR` | Re-run last session |

---

## Updates

```vim
:TeaVimUpdate
```

Or press `<Space>U` from anywhere inside Neovim.

---

## License

MIT
