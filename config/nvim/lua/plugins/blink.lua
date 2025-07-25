local kind_icons = {
  -- LLM Provider icons
  claude = "󰋦",
  openai = "󱢆",
  codestral = "󱎥",
  gemini = "",
  Groq = "",
  Openrouter = "󱂇",
  Ollama = "󰳆",
  ["Llama.cpp"] = "󰳆",
  Deepseek = "",
}
return {
  "saghen/blink.cmp",
  dependencies = {
    { "rafamadriz/friendly-snippets" },
    { "cstrap/python-snippets" },
    { "saghen/blink.compat", lazy = true, verson = false },
    -- { "Kaiser-Yang/blink-cmp-avante" },
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
        selection = { preselect = false, auto_insert = false },
      },
      trigger = {
        prefetch_on_insert = false,
      },
      accept = { auto_brackets = { enabled = true } },
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
      kind_icons = kind_icons,
    },
    signature = { enabled = true },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        -- "markdown",
        "minuet",
      },

      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          score_offset = 8, -- Gives minuet higher priority among suggestions
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
