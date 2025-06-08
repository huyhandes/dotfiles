return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    provider = "claude_yescale",
    -- behaviour = {
    --   enable_cursor_planning_mode = true,
    -- },
    cursor_applying_provider = "groq",
    providers = {
      claude_yescale = {
        __inherited_from = "openai",
        api_key_name = "ANTHROPIC_API_KEY",
        endpoint = "https://api.yescale.io/v1",
        model = "claude-sonnet-4-20250514",
      },
      openai = {
        endpoint = "https://api.yescale.io/v1",
        model = "gpt-4.1-mini-2025-04-14", -- your desired model (or use gpt-4o, etc.)
        extra_request_body = {
          temperature = 0.75,
          max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
        },
      },
      groq = { -- define groq provider
        __inherited_from = "openai",
        api_key_name = "GROQ_API_KEY",
        endpoint = "https://api.groq.com/openai/v1/",
        model = "llama-3.3-70b-versatile",
        extra_request_body = {
          max_completion_tokens = 32768,
        },
      },
      gemini_deepthink = {
        __inherited_from = "gemini",
        model = "gemini-2.5-flash-preview-05-20",
        extra_request_body = {
          generationConfig = {
            thinkingConfig = {
              thinkingBudget = 24576,
            },
          },
        },
      },
      gemini_no_reasoning = {
        __inherited_from = "gemini",
        model = "gemini-2.5-flash-preview-05-20",
        extra_request_body = {
          generationConfig = {
            thinkingConfig = {
              thinkingBudget = 0,
            },
          },
        },
      },
      selector = {
        provider = "snacks",
      },
      rag_service = {
        enabled = true, -- Enables the RAG service
        host_mount = os.getenv("HOME"), -- Host mount path for the rag service
        provider = "openai", -- The provider to use for RAG service (e.g. openai or ollama)
        llm_model = "gpt-4.1-mini-2025-04-14", -- The LLM model to use for RAG service
        embed_model = "Alibaba-NLP/gte-modernbert-base", -- The embedding model to use for RAG service
        endpoint = "http://192.168.6.18:18880/v1", -- The API endpoint for RAG service
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
    { "stevearc/dressing.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
  },
}
