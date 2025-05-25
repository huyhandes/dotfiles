return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
  },
  opts = {
    adapters = {
      anthropic_chat = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            api_key = "YESCALE_ANTHROPIC_API_KEY",
            url = "https://api.yescale.io",
          },
          schema = {
            model = {
              default = "claude-3-7-sonnet-20250219-thinking",
            },
          },
        })
      end,
      -- gemini_chat = function()
      --   return require("codecompanion.adapters").extend("gemini", {
      --     schema = {
      --       model = {
      --         default = "gemini-2.5-pro-exp-03-25",
      --       },
      --     },
      --   })
      -- end,
      anthropic_inline = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            api_key = "YESCALE_ANTHROPIC_API_KEY",
            url = "https://api.yescale.io",
          },
          schema = {
            model = {
              default = "claude-3-7-sonnet-20250219",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "anthropic_chat",
      },
      inline = {
        adapter = "anthropic_inline",
      },
    },
    extensions = {
      vectorcode = {
        opts = {
          add_tool = true,
        },
      },
      -- mcphub = {
      --   callback = "mcphub.extensions.codecompanion",
      --   opts = {
      --     make_vars = true,
      --     make_slash_commands = true,
      --     show_result_in_chat = true,
      --   },
      -- },
    },
  },
}
