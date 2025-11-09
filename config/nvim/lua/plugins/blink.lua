return {
  "saghen/blink.cmp",
  dependencies = {
    { "rafamadriz/friendly-snippets" },
  },
  version = "1.*",
  opts = {
    keymap = {
      preset = "enter",
    },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      list = {
        selection = { preselect = false, auto_insert = false },
      },
      trigger = {
        show_on_keyword = true
      },
      menu = {
        draw = {
          columns = {
            { "kind_icon", "kind", gap = 1 }, { "label", "label_description" }
          },
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                return kind_icon
              end,
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
            kind = {
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            }
          }
        }
      },
    },
    signature = { enabled = true },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "omni"
      },
    },
  },
  opts_extend = { "sources.default" },
}
