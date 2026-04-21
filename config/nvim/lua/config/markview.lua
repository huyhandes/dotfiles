require("markview").setup({
  preview = {
    filetypes = { "markdown" },
    ignore_buftypes = {},
    icon_provider = "mini",
    modes = { "n", "no", "c", "i" },
    hybrid_modes = { "i", "n" },
    linewise_hybrid_mode = true,
  },
})
