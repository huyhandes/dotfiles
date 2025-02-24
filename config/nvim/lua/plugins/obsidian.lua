return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- enable = false,
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    -- refer to `:h file-pattern` for more examples
    "BufReadPre "
      .. vim.fn.expand("~")
      .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Handes/**.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Handes/**.md",
  },
  dependencies = {
    -- Required.
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "nvim-treesitter/nvim-treesitter" },
    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "Handes",
        path = vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Handes",
      },
    },
    notes_subdir = "6. Random Notes",
    new_notes_localtion = "notes_subdir",
    templates = {
      folder = "5. Templates",
    },
    daily_notes = {
      folder = "Notes/Daily",
      template = "Daily Note Template.md",
    },
  },
  config = function(_, opts)
    opts.mappings = opts.mappings or {} -- ✅ Ensure mappings exist
    opts.mappings["<CR>"] = nil -- ✅ Correct way to disable Enter remap
    opts.ui = { enable = false }
    -- Ensure Obsidian is set up correctly
    require("obsidian").setup(opts)
  end,
}
