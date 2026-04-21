require("mason").setup()

vim.opt.signcolumn = "yes"

vim.lsp.config("ruff", {
  init_options = { settings = { lineLength = 88, lint = { enable = true } } },
})
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
      gofumpt = true,
    },
  },
})
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.enable({
  "lua_ls",
  "docker_compose_language_service",
  "dockerls",
  "basedpyright",
  "gopls",
  "ruff",
})
