return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspInstall", "LspStart" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", opts = {} },
    { "saghen/blink.cmp" },
  },
  init = function() vim.opt.signcolumn = "yes" end,
  config = function()
    vim.lsp.enable({
      "lua_ls",
      "docker_compose_language_service",
      "dockerls",
      "basedpyright",
      "metals",
      "gopls",
      "ruff",
    })
    vim.lsp.config("ruff", {
      init_options = { settings = { lineLength = 88, lint = { enable = true } } },
    })
    vim.lsp.config("metals", {
      filetypes = { "scala", "sbt" },
    })
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
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
  end,
}
