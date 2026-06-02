-- DAP (Debug Adapter Protocol) setup.
-- Provides inline breakpoints, step-through debugging, and a dap-ui panel.

local dap    = require("dap")
local dapui  = require("dapui")

-- ── dap-ui ────────────────────────────────────────────────────────────────────
dapui.setup({
  icons = { expanded = "", collapsed = "", current_frame = "" },
  layouts = {
    {
      elements = {
        { id = "scopes",      size = 0.35 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks",      size = 0.25 },
        { id = "watches",     size = 0.20 },
      },
      size     = 40,
      position = "left",
    },
    {
      elements = {
        { id = "repl",    size = 0.5 },
        { id = "console", size = 0.5 },
      },
      size     = 12,
      position = "bottom",
    },
  },
  floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
  controls = {
    enabled = true,
    element  = "repl",
    icons = {
      pause        = "",
      play         = "",
      step_into    = "",
      step_over    = "",
      step_out     = "",
      step_back    = "",
      run_last     = "",
      terminate    = "",
    },
  },
})

-- Auto-open/close the UI when a debug session starts/ends.
dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

-- ── Inline virtual-text (current line values) ─────────────────────────────────
local ok_vt, dap_vt = pcall(require, "nvim-dap-virtual-text")
if ok_vt then
  dap_vt.setup({
    enabled                  = true,
    enabled_commands         = true,
    highlight_changed_variables = true,
    show_stop_reason         = true,
    commented                = false,
    virt_text_pos            = "eol",
  })
end

-- ── Breakpoint signs ──────────────────────────────────────────────────────────
vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",         linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPoint",            linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStoppedLine", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "✗", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })

-- Highlight the stopped line.
vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e3440", bold = true })

-- ── Language adapters ─────────────────────────────────────────────────────────

-- Python (debugpy — installed via Mason's DAP registry)
local ok_py, dap_py = pcall(require, "dap-python")
if ok_py then
  local mason_py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
  dap_py.setup(mason_py)
end

-- JavaScript / TypeScript (js-debug-adapter via Mason)
for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
  dap.adapters[adapter] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = {
        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
        "${port}",
      },
    },
  }
end

for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[lang] = {
    {
      type    = "pwa-node",
      request = "launch",
      name    = "Launch file",
      program = "${file}",
      cwd     = "${workspaceFolder}",
    },
    {
      type      = "pwa-node",
      request   = "attach",
      name      = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd       = "${workspaceFolder}",
    },
    {
      type    = "pwa-chrome",
      request = "launch",
      name    = "Launch Chrome",
      url     = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
    },
  }
end

-- Go (delve — installed via Mason)
dap.adapters.go = {
  type      = "server",
  port      = "${port}",
  executable = {
    command = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv",
    args    = { "dap", "-l", "127.0.0.1:${port}" },
  },
}
dap.configurations.go = {
  { type = "go", name = "Debug",      request = "launch", program = "${file}" },
  { type = "go", name = "Debug test", request = "launch", program = "${file}", mode = "test" },
  { type = "go", name = "Debug package", request = "launch", program = "${workspaceFolder}" },
}

-- Rust / C / C++ (codelldb — installed via Mason)
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
    args    = { "--port", "${port}" },
  },
}
for _, lang in ipairs({ "rust", "c", "cpp" }) do
  dap.configurations[lang] = {
    {
      type    = "codelldb",
      request = "launch",
      name    = "Launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd          = "${workspaceFolder}",
      stopOnEntry  = false,
    },
  }
end
