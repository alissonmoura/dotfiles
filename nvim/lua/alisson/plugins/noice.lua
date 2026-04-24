return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    --"rcarriga/nvim-notify",
  },
  routes = {
    {
      view = "notify",
      filter = { event = "msg_showmode" },
    },
  },
  config = function()
    local noice = require("noice")
    noice.setup({

      -- fix macro promt command
      routes = {
        {
          view = "notify",
          filter = { event = "msg_showmode" },
        },
      },

      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    })

    -- fix macro promt command
    require("lualine").setup({
      sections = {
        lualine_x = {
          {
            noice.api.statusline.mode.get,
            cond = noice.api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
        },
      },
    })
  end,
}
