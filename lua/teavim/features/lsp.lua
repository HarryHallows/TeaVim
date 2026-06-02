-- LSP setup: Mason installs servers, mason-lspconfig wires them to nvim-lspconfig,
-- blink.cmp provides completion (configured via its own plugin spec in plugins.lua).

require("fidget").setup({})
require("mason").setup({ ui = { border = "rounded" } })

local mason_lsp = require("mason-lspconfig")
local lspconfig = require("lspconfig")

-- Capabilities advertised to each server (blink.cmp extends these).
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local function on_attach(_, bufnr)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
  })
end

-- Per-server overrides; anything not listed gets default setup.
local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim", "TeaVim" } },
        workspace   = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
        telemetry   = { enable = false },
      },
    },
  },
}

mason_lsp.setup({
  ensure_installed = {
    "lua_ls", "ts_ls", "pyright", "rust_analyzer",
    "gopls",  "jsonls", "html",   "cssls", "tailwindcss",
    "bashls", "dockerls",
  },
  automatic_installation = true,
  handlers = {
    -- Default handler for every installed server.
    function(server_name)
      local cfg = server_configs[server_name] or {}
      cfg.capabilities = capabilities
      cfg.on_attach    = on_attach
      lspconfig[server_name].setup(cfg)
    end,
  },
})

-- Diagnostic display
vim.diagnostic.config({
  virtual_text     = { prefix = "●" },
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = "rounded", source = "always" },
})
