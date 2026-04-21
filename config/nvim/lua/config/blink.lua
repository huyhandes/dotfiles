local function get_mini_icon(ctx)
  if ctx.source_name == "Path" then
    local is_unknown_type = vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, ctx.item.data.type)
    local mini_icon, mini_hl, _ = require("mini.icons").get(is_unknown_type and "os" or ctx.item.data.type, is_unknown_type and "" or ctx.label)
    if mini_icon then return mini_icon, mini_hl end
  end
  local mini_icon, mini_hl, _ = require("mini.icons").get("lsp", ctx.kind)
  return mini_icon, mini_hl
end

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  cmdline = {
    keymap = {
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
    },
    completion = {
      menu = { auto_show = true },
      list = { selection = { preselect = false, auto_insert = false } },
    },
  },
  completion = {
    list = {
      selection = { preselect = false, auto_insert = false },
    },
    menu = {
      draw = {
        components = {
          kind_icon = {
            text = function(ctx)
              local kind_icon, kind_hl = get_mini_icon(ctx)
              return kind_icon
            end,
            -- (optional) use highlights from mini.icons
            highlight = function(ctx)
              local _, hl = get_mini_icon(ctx)
              return hl
            end,
          },
          kind = {
            -- (optional) use highlights from mini.icons
            highlight = function(ctx)
              local _, hl = get_mini_icon(ctx)
              return hl
            end,
          },
        },
      },
    },
  },
  signature = { enabled = true },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer", "omni" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
        fallbacks = { "lsp" },
      },
    },
  },
})
