return {
  "saghen/blink.cmp",
  dependencies = {
    { "rafamadriz/friendly-snippets" },
    { "cstrap/python-snippets" },
    { "saghen/blink.compat", lazy = true, verson = false },
  },
  version = "*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "enter",
    },
    completion = {
      list = {
        selection = { preselect = false, auto_insert = true },
      },
      menu = {
        draw = {
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              -- Optionally, you may also use the highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
        },
      },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "normal",
    },
    signature = { enabled = true },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "minuet",
        "avante_commands",
        "avante_mentions",
        "avante_files",
        "obsidian",
        "obsidian_new",
        "obsidian_tags",
      },
      per_filetype = {
        codecompanion = { "codecompanion" },
      },
      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          score_offset = 8, -- Gives minuet higher priority among suggestions
        },
        obsidian = { name = "obsidian", module = "blink.compat.source" },
        obsidian_new = { name = "obsidian_new", module = "blink.compat.source" },
        obsidian_tags = { name = "obsidian_tags", module = "blink.compat.source" },
        avante_commands = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 90, -- show at a higher priority than lsp
          opts = {},
        },
        avante_files = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 100, -- show at a higher priority than lsp
          opts = {},
        },
        avante_mentions = {
          name = "avante_mentions",
          module = "blink.compat.source",
          score_offset = 1000, -- show at a higher priority than lsp
          opts = {},
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
