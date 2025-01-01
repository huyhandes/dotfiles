return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspInstall", "LspStart" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "williamboman/mason.nvim" },
    -- { "williamboman/mason-lspconfig.nvim" },
    -- { "saghen/blink.cmp" },
  },
  init = function()
    vim.opt.signcolumn = "yes"
  end,
  opts = {
    servers = {
      lua_ls = {},
      basedpyright = {},
    },
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    local mason = require("mason-registry")
    local lsp_defaults = lspconfig.util.default_config

    lsp_defaults.capabilities =
      vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

    local function setup_lsp(name, lsp_opts)
      if mason.is_installed(name) then
        lspconfig[name].setup(lsp_opts)
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
    })

    setup_lsp("ruff", { init_options = { settings = { lineLength = 88, lint = { enable = true } } } })

    for server, config in pairs(opts.servers) do
      -- passing config.capabilities to blink.cmp merges with the capabilities in your
      -- `opts[server].capabilities, if you've defined it
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end
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
