require("blink.pairs").download():pwait(60000)
require("blink.pairs").setup({
  mappings = {
    enabled = true,
    cmdline = true,
    disabled_filetypes = {},
  },
  highlights = {
    enabled = true,
    cmdline = true,
    groups = { "BlinkPairsOrange", "BlinkPairsPurple", "BlinkPairsBlue" },
    unmatched_group = "BlinkPairsUnmatched",
    matchparen = {
      enabled = true,
      group = "BlinkPairsMatchParen",
      priority = 250,
    },
  },
})
