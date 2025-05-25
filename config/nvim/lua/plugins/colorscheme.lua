return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function(opts)
      -- load the colorscheme here
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          blink_cmp = true,
          mini = {
            enabled = true,
          },
          gitsigns = true,
          mason = true,
          treesitter = true,
          neotree = true,
          telescope = true,
        },
      })
      vim.cmd.colorscheme("catppuccin-macchiato")
      vim.opt.colorcolumn = "89"
    end,
  },
}
