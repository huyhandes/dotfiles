return {
  "echasnovski/mini.nvim",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  version = "*",
  config = function()
    require("mini.ai").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.diff").setup()
    require("mini.icons").setup({
      style = "glyph",
    })
    MiniIcons.mock_nvim_web_devicons()
    require("mini.statusline").setup({
      content = {
        active = function()
          local mini = require("mini.statusline")
          local mode, mode_hl = mini.section_mode({ trunc_width = 120 })
          local diagnostics = mini.section_diagnostics({ trunc_width = 75 })
          local lsp = mini.section_lsp({ icon = MiniIcons.get("lsp", "keyword"), trunc_width = 75 })
          local filename = mini.section_filename({ trunc_width = 140 })
          local percent = "%2p%%"
          local location = "%3l:%-2c"

          return mini.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { diagnostics, lsp } },
            "%<", -- Mark general truncate point
            { hl = "MiniStatuslineFilename", strings = { filename } },
            "%=", -- End left alignment
            { hl = "MiniStatuslineFilename", strings = { "%{&filetype}" } },
            { hl = "MiniStatuslineFileinfo", strings = { percent } },
            { hl = mode_hl, strings = { location } },
          })
        end,
      },
    })
    require("mini.comment").setup({
      options = {
        custom_commentstring = function()
          local cs = require("ts_context_commentstring").calculate_commentstring()
          return cs or vim.bo.commentstring
        end,
      },
    })
  end,
}
