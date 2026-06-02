-- TeaVim entry point
-- Bootstraps lazy.nvim, loads user config, applies profile, loads features.

-- Ensure this repo's lua directory is on the path when running directly
-- (e.g. NVIM_APPNAME=teavim nvim, or before install.sh has been run).
vim.opt.rtp:prepend(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h"))

require("teavim.bootstrap")
require("teavim.config")
require("teavim.options")
require("teavim.plugins")
require("teavim.keymaps.core")
require("teavim.onboarding")
require("teavim.onboarding.reset")
require("teavim.update")
