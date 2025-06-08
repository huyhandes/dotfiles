return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        default_integrations = false,
        integrations = {
          blink_cmp = true,
          mini = { enabled = true },
          gitsigns = true,
          mason = true,
          markview = true,
          treesitter = true,
          rainbow_delimiters = true,
          snacks = {
            enabled = true,
          },
        },
      })
      vim.cmd.colorscheme("catppuccin-macchiato")
      vim.opt.colorcolumn = "89"
    end,
  },
}
