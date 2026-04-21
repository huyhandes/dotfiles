require("nvim-tmux-navigation").setup({})

local map = vim.keymap.set
map("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>")
map("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>")
map("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>")
map("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>")
