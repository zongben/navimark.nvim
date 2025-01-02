# navimark.nvim

An easy and powerful bookmark manager with telescope

https://github.com/user-attachments/assets/4c0d3a0c-c911-40e9-8d0a-d70099a40e8c

## Features

- Displays a bookmark sign wherever you set it
- Bookmarks are scoped by different stacks
- Uses telescope to preview and navigate bookmarks
- Allows bookmarks to be persisted

## Installation

With lazy.nvim
```lua
{
  "zongben/navimark.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  }
  config = function()
    require("navimark").setup()
  end,
}
```

## Configuration

The default configuration is as follows
```lua
{
  keymap = {
    base = {
      mark_toggle = "<leader>mm",
      mark_add = "<leader>ma",
      mark_remove = "<leader>mr",
      goto_next_mark = "<leader>mn",
      goto_prev_mark = "<leader>mp",
      open_mark_picker = "<leader>fm",
    },
    telescope = {
      n = {
        delete_mark = "d",
        new_stack = "n",
        next_stack = "<Tab>",
        prev_stack = "<S-Tab>",
        rename_stack = "r",
        delete_stack = "D",
      },
    },
  },
  sign = {
    text = "",
    color = "#FF0000",
  },
  persist = false,
}
```
