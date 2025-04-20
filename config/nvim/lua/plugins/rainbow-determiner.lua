return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufRead",
  lazy = true,
  version = "*",
  submodules = false,
  config = function()
    require("rainbow-delimiters.setup").setup()
  end,
}
