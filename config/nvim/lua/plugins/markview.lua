return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  priority = 49,
  opts = {
    preview = {
      filetypes = { "markdown", "Avante", "codecompanion" },
      ignore_buftypes = {},
      icon_provider = "mini",
      modes = { "n", "no", "c", "i" },
      hybrid_modes = { "i", "n" },
      linewise_hybrid_mode = true,
    },
  },
}
