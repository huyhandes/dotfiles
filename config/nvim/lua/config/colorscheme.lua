require("catppuccin").setup({
  transparent_background = true,
  default_integrations = false,
  integrations = {
    blink_cmp = {
      style = "bordered",
    },
    blink_indent = true,
    blink_pairs = true,
    mini = { enabled = true },
    gitsigns = true,
    mason = true,
    markview = true,
    treesitter = true,
  },
})
vim.cmd.colorscheme("catppuccin-macchiato")
vim.opt.colorcolumn = "89"
