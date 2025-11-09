return {
  "milanglacier/minuet-ai.nvim",
  config = function()
    require("minuet").setup({
      cmp = {
        enable_auto_complete = false,
      },
      provider = "codestral",
      provider_options = {
        codestral = {
          optional = {
            max_tokens = 256,
            stop = { "\n\n" },
          },
        },
        -- openai_fim_compatible = {
        --   model = "qwen2.5-coder:1.5b",
        --   end_point = os.getenv("OLLAMA_API_URL") .. "/completions",
        --   api_key = "OLLAMA_API_KEY",
        --   name = "Ollama",
        --   stream = true,
        --   optional = {
        --     stop = nil,
        --     max_tokens = 256,
        --   },
        -- },
      },
    })
  end,
}
