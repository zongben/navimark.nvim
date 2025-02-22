# navimark.nvim

An easy and powerful bookmark manager with telescope

https://github.com/user-attachments/assets/4c0d3a0c-c911-40e9-8d0a-d70099a40e8c

## Features

- Displays a bookmark sign wherever you set it
- Bookmarks are scoped by different stacks
- Uses telescope to preview and navigate bookmarks
- Allows bookmarks to be persisted
- **(NEW)** When LSP attached, stack will be autoloaded and named based on the current repository

## Installation

With lazy.nvim
```lua
{
  "zongben/navimark.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("navimark").setup()
  end,
}
```

## Configuration

The default configuration is as follows
```lua
{
  --set "" to disable keymapping
  keymap = {
    base = {
      mark_toggle = "<leader>mm",
      mark_add = "<leader>ma",
      mark_remove = "<leader>mr",
      goto_next_mark = "]m",
      goto_prev_mark = "[m",
      open_mark_picker = "<leader>fm",
    },
    telescope = {
      n = {
        delete_mark = "d",
        clear_marks = "c",
        new_stack = "n",
        next_stack = "<Tab>",
        prev_stack = "<S-Tab>",
        rename_stack = "r",
        delete_stack = "D",
        -- open all marked files in current stack
        open_all_marked_files = "<C-o>", 
      },
    },
  },
  sign = {
    text = "",
    color = "#FF0000",
  },
  --set to true to persist marks
  persist = false,

  --options: manual || auto
  --auto: when LSP attached, stack will be autoloaded and named based on the current repository
  --manual: manage stacks manually
  stack_mode = "manual",
}
```

## API

You can use the following APIs to customize your config
```lua
local stack = require("navimark.stack")
stack.mark_toggle()
stack.mark_add()
stack.mark_remove()
stack.goto_next_mark()
stack.goto_prev_mark()
```
