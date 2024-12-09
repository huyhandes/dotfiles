return {

  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",
        provider_options = {
          openai_fim_compatible = {
            model = "qwen2.5-coder:1.5b",
            end_point = os.getenv("OLLAMA_API_URL") .. "/completions",
            api_key = "OLLAMA_API_KEY",
            name = "Ollama",
            stream = true,
            optional = {
              stop = nil,
              max_tokens = 256,
            },
          },
        },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },
  { "hrsh7th/nvim-cmp" },
}
