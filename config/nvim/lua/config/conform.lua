require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = {
      "ruff_fix",
      "ruff_format",
      "ruff_organize_imports",
    },
    json = { "jq" },
    go = { "gofumpt" },
  },
  format_on_save = { timeout_ms = 500 },
})

vim.keymap.set("", "<leader>fc", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
