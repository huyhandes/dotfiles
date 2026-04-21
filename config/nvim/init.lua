require("core")

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/romus204/tree-sitter-manager.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
  { src = "https://github.com/saghen/blink.pairs", version = vim.version.range("*") },
  { src = "https://github.com/saghen/blink.download" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/OXY2DEV/markview.nvim" },
  { src = "https://github.com/catgoose/nvim-colorizer.lua", name = "nvim-colorizer" },
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
})

require("config.colorscheme")
require("config.treesitter")
require("config.mini")
require("config.lsp")
require("config.blink")
require("config.pairs")
require("config.conform")
require("config.gitsigns")
require("config.markview")
require("config.colorizer")
require("config.lazydev")
require("config.tmux-nav")

vim.api.nvim_create_user_command("PackUpdate", function() vim.pack.update() end, { desc = "Update plugins" })
vim.api.nvim_create_user_command("PackStatus", function() vim.print(vim.pack.get()) end, { desc = "Plugin status" })
vim.api.nvim_create_user_command("PackClean", function()
  local inactive = {}
  for _, p in ipairs(vim.pack.get()) do
    if not p.active then table.insert(inactive, p.spec.name) end
  end
  if #inactive == 0 then
    vim.notify("No inactive plugins")
  else
    vim.pack.del(inactive)
  end
end, { desc = "Remove inactive plugins" })
