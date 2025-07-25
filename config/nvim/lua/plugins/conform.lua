return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>fc",
      function() require("conform").format({ async = true, lsp_fallback = true }) end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = {
        -- To fix auto-fixable lint errors.
        "ruff_fix",
        -- To run the Ruff formatter.
        "ruff_format",
        -- To organize the imports.
        "ruff_organize_imports",
      },
      json = { "jq" },
      go = { "gofumpt" },
    },
    -- default_format_opts = {
    --   lsp_format = "fallback",
    -- },
    format_on_save = { timeout_ms = 500 },
  },
}
