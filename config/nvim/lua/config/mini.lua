vim.g.skip_ts_context_commentstring_module = true
require("ts_context_commentstring").setup({ enable_autocmd = false })

local mini_icons = function()
  require("mini.icons").setup({ style = "glyph" })
  MiniIcons.mock_nvim_web_devicons()
  MiniIcons.tweak_lsp_kind()
end

local mini_simple = function()
  require("mini.ai").setup()
  require("mini.surround").setup()
  require("mini.tabline").setup()
  require("mini.bufremove").setup()
  require("mini.comment").setup({
    options = {
      custom_commentstring = function()
        local cs = require("ts_context_commentstring").calculate_commentstring()
        return cs or vim.bo.commentstring
      end,
    },
  })
end

local mini_statusline = function()
  require("mini.statusline").setup({
    content = {
      active = function()
        local mini = require("mini.statusline")
        local mode, mode_hl = mini.section_mode({ trunc_width = 120 })
        local diagnostics = mini.section_diagnostics({ trunc_width = 75 })
        local lsp = mini.section_lsp({ icon = MiniIcons.get("lsp", "keyword"), trunc_width = 75 })
        local filename = mini.section_filename({ trunc_width = 140 })
        local percent = "%2p%%"
        local location = "%3l:%-2c"

        return mini.combine_groups({
          { hl = mode_hl,                  strings = { mode } },
          { hl = "MiniStatuslineDevinfo",  strings = { diagnostics, lsp } },
          "%<",
          { hl = "MiniStatuslineFilename", strings = { filename } },
          "%=",
          { hl = "MiniStatuslineFilename", strings = { "%{&filetype}" } },
          { hl = "MiniStatuslineFileinfo", strings = { percent } },
          { hl = mode_hl,                  strings = { location } },
        })
      end,
    },
  })
end

local mini_files = function()
  require("mini.files").setup({
    mappings = {
      go_in = "l",
      go_out = "h",
      go_in_plus = "",
      go_out_plus = "",
    },
    options = {
      permanent_delete = true,
      use_as_default_explorer = true,
    },
    windows = {
      preview = false,
      width_nofocus = 30,
      width_focus = 30,
    },
  })

  local is_active = function() return MiniFiles.get_explorer_state() end
  vim.keymap.set("n", "<leader>e", function()
    if is_active() then return end
    MiniFiles.open()
  end, { desc = "Explorer (cwd)" })
  vim.keymap.set("n", "<leader>E", function()
    if is_active() then return end
    if not vim.bo.buflisted then return end
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  end, { desc = "Explorer (file dir)" })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesExplorerOpen",
    callback = function()
      MiniFiles.set_bookmark("c", vim.fn.stdpath("config"))
      MiniFiles.set_bookmark("w", vim.fn.getcwd())
      MiniFiles.set_bookmark("h", "~")
    end,
  })

  local showdot = true
  local fshow = function(_) return true end
  local fhide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end
  local toggle_dot = function()
    showdot = not showdot
    MiniFiles.refresh({ content = { filter = showdot and fshow or fhide } })
  end

  local yank_path = function()
    local path = (MiniFiles.get_fs_entry() or {}).path
    if path then vim.fn.setreg("+", path) end
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = args.data.buf_id }) end
      map("<C-h>", toggle_dot)
      map("gy", yank_path)
    end,
  })
end

local mini_pick = function()
  require("mini.pick").setup({
    mappings = {
      move_down = "<C-j>",
      move_up   = "<C-k>",
      choose_in_split  = "<C-s>",
      choose_in_vsplit = "<C-v>",
      choose_in_tabpage = "<C-t>",
      scroll_down = "<C-d>",
      scroll_up   = "<C-u>",
    },
  })
  vim.ui.select = MiniPick.ui_select

  local map = vim.keymap.set
  map("n", "<leader>ff", MiniPick.builtin.files,     { desc = "Find Files" })
  map("n", "<leader>fz", MiniPick.builtin.grep_live, { desc = "Grep" })
  map("n", "<leader>fb", function() MiniPick.builtin.buffers({ include_unlisted = true }) end, { desc = "Buffers" })
  map("n", "<leader>fh", MiniPick.builtin.help,      { desc = "Help" })
  map("n", "<leader>fc", MiniPick.builtin.resume,    { desc = "Resume picker" })
end

local mini_extra = function()
  require("mini.extra").setup()
  local map = vim.keymap.set
  map("n", "<leader>sd", MiniExtra.pickers.diagnostic, { desc = "Diagnostics" })
  map("n", "<leader>fo", MiniExtra.pickers.oldfiles,   { desc = "Old files" })
  map("n", "<leader>fm", MiniExtra.pickers.marks,      { desc = "Marks" })
  map("n", "<leader>fk", MiniExtra.pickers.keymaps,    { desc = "Keymaps" })
  map("n", "<leader>fr", MiniExtra.pickers.registers,  { desc = "Registers" })
  map("n", "<leader>gh", MiniExtra.pickers.git_hunks,    { desc = "Git hunks" })
  map("n", "<leader>gc", MiniExtra.pickers.git_commits,  { desc = "Git commits" })
  map("n", "<leader>gb", MiniExtra.pickers.git_branches, { desc = "Git branches" })
  -- LSP fuzzy pickers (augment native grr/gri/grt/gra)
  map("n", "gd", function() MiniExtra.pickers.lsp({ scope = "definition" }) end, { desc = "LSP Definition" })
  map("n", "gr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "LSP References" })
  map("n", "gI", function() MiniExtra.pickers.lsp({ scope = "implementation" }) end, { desc = "LSP Implementation" })
  map("n", "gy", function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end, { desc = "LSP Type Def" })
end

local mini_bufkeys = function()
  vim.keymap.set("n", "<leader>bd", function() MiniBufremove.delete(0, false) end, { desc = "Delete Buffer" })
  vim.keymap.set("n", "<leader>gg", function() vim.cmd("tabnew | term lazygit") end, { desc = "Lazygit" })
end

local mini_notify = function()
  require("mini.notify").setup({
    content = {
      format = function(notif)
        if notif.data.source == "lsp_progress" then return notif.msg end
        return MiniNotify.default_format(notif)
      end,
      sort = function(arr)
        table.sort(arr, function(a, b) return a.ts_update > b.ts_update end)
        return arr
      end,
    },
    window = { winblend = 0 },
  })
  vim.notify = MiniNotify.make_notify({
    ERROR = { duration = 5000, hl_group = "DiagnosticError" },
    WARN  = { duration = 3000, hl_group = "DiagnosticWarn" },
    INFO  = { duration = 3000, hl_group = "DiagnosticInfo" },
    DEBUG = { duration = 1000, hl_group = "DiagnosticHint" },
  })
end

mini_icons()
mini_notify()
mini_simple()
mini_statusline()
mini_files()
mini_pick()
mini_extra()
mini_bufkeys()
