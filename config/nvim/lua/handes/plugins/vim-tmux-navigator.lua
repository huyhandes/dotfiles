return {
    "christoomey/vim-tmux-navigator", -- tmux & split window navigation
    vim.keymap.set('n', 'C-h', ':TmuxNavigateLeft<cr>'),
    vim.keymap.set('n', 'C-j', ':TmuxNavigateDown<cr>'),
    vim.keymap.set('n', 'C-k', ':TmuxNavigateUp<cr>'),
    vim.keymap.set('n', 'C-l', ':TmuxNavigateRight<cr>'),
}