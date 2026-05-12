return {
  {
    "iamcco/markdown-preview.nvim",
    --build = function()
    --  vim.fn["mkdp#util#install"]()
    --end,
    build = "cd app && npm install",
    ft = { "markdown" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }

      vim.g.mkdp_preview_options = {
        -- The 'uml' table holds PlantUML configurations
        uml = {
          -- Specify your PlantUML server URL
          server = "http://localhost:8080", -- Replace with your actual server address
        },
        -- You can keep other default settings or add more options here
        -- mkit = {},
        -- katex = {},
        -- disable_sync_scroll = 0,
        -- sync_scroll_type = 'middle',
      }
    end,
  },
}
