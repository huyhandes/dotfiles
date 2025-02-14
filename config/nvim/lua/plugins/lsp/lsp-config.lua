return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspInstall", "LspStart" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim" },
    { "saghen/blink.cmp" },
  },
  init = function()
    vim.opt.signcolumn = "yes"
  end,
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    local mason = require("mason-registry")
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    local lsp_mapping = {}
    lsp_mapping["lua-language-server"] = "lua_ls"

    local function setup_lsp(name, server_opts)
      local lsp_name = lsp_mapping[name]
      if lsp_name == nil then
        lsp_name = name
      end
      if mason.is_installed(name) then
        lspconfig[lsp_name].setup(server_opts)
      end
    end

    setup_lsp("basedpyright", {
      settings = {
        basedpyright = {
          analysis = {
            autoImportCompletions = true,
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
      autostart = false,
      capabilities = capabilities,
    })

    setup_lsp(
      "ruff",
      { init_options = { settings = { lineLength = 88, lint = { enable = true } } }, capabilities = capabilities }
    )
    setup_lsp("lua-language-server", { capabilities = capabilities })

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local lsp_opts = { buffer = event.buf }

        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", lsp_opts)
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", lsp_opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", lsp_opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", lsp_opts)
        vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", lsp_opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", lsp_opts)
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", lsp_opts)
        vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", lsp_opts)
        vim.keymap.set("n", "<F3>", vim.lsp.buf.code_action, lsp_opts)
        vim.keymap.set("n", "<leader>/", vim.diagnostic.open_float, lsp_opts)
      end,
    })
  end,
}
