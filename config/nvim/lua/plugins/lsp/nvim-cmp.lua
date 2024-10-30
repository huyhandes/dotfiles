return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-buffer",
  },
  event = { "InsertEnter", "CmdlineEnter" },
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    table.insert(opts.sources, {
      name = "lazydev",
      group_index = 0, -- set group index to 0 to skip loading LuaLS completions
    })
  end,
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
        -- ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
    })
  end,
}
