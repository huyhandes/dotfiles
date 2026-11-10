require("markview").setup({
  preview = {
    filetypes = { "markdown" },
    ignore_buftypes = {},
    icon_provider = "mini",
    modes = { "n", "no", "c", "i" },
    hybrid_modes = { "n", "v", "V", "i" },
  },
  renderers = {
    markdown_table = function(buffer, item) require("markview-smart-tables").render(buffer, item) end,
  },
})
