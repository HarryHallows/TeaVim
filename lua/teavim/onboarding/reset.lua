-- :TeaVimReset — wipe onboarding state so it shows again on next launch.
vim.api.nvim_create_user_command("TeaVimReset", function()
  local path = vim.fn.stdpath("data") .. "/teavim_onboarding.json"
  vim.fn.delete(path)
  vim.notify("TeaVim: onboarding reset. Restart Neovim to see it again.", vim.log.levels.INFO)
end, { desc = "Reset TeaVim onboarding state" })
