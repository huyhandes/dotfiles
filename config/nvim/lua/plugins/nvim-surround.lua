return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
      keymaps = {
        insert = "<C-s>",
        normal = "s",
        normal_cur = "ss",
        visual = "s",
      },
      aliases = {
        ["a"] = ">",
        ["p"] = ")",
        ["c"] = "}",
        ["r"] = "]",
        ["b"] = { "}", "]", ")", ">" },

        ["A"] = "<",
        ["P"] = "(",
        ["C"] = "{",
        ["R"] = "[",
        ["B"] = { "<", "(", "{", "[" },

        ["j"] = '"',
        ["k"] = "'",
        ["l"] = "`",
        ["q"] = { '"', "'", "`" },

        ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
      },
      indent_lines = false,
    })
  end,
}
