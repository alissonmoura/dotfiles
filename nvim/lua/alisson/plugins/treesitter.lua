return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  dependencies = {
    "neovim-treesitter/treesitter-parser-registry",
    "windwp/nvim-ts-autotag",
    {
      "nvim-treesitter/nvim-treesitter-context", -- Show code context
      opts = {
        enable = true,
        mode = "topline",
        line_numbers = true,
      },
    },
  },
  config = function()
    local treesitter = require("nvim-treesitter")
    -- "vim" and "vimdoc" are bundled with Neovim 0.12+ (parser + queries)
    -- so we skip them here to avoid query incompatibilities.
    local parsers = {
      "json",
      "yaml",
      "html",
      "markdown",
      "markdown_inline",
      "bash",
      "lua",
      "dockerfile",
      "gitignore",
      "query",
      "c",
      "go",
      "gomod",
      "gowork",
      "gosum",
      "cmake",
    }
    local parser_set = {}

    for _, parser in ipairs(parsers) do
      parser_set[parser] = true
    end

    local function enable_treesitter(buf)
      local ft = vim.bo[buf].filetype
      local parser = vim.treesitter.language.get_lang(ft) or ft

      if parser_set[parser] then
        vim.treesitter.start(buf)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    treesitter.setup({})
    require("nvim-ts-autotag").setup({})

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        enable_treesitter(args.buf)
      end,
    })

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        enable_treesitter(buf)
      end
    end
  end,
}
