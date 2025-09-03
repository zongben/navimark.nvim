# navimark.nvim

An easy and powerful bookmark manager with telescope

https://github.com/user-attachments/assets/4c0d3a0c-c911-40e9-8d0a-d70099a40e8c

## Features

- Displays a bookmark sign wherever you set it
- Bookmarks are scoped by different stacks
- Uses telescope to preview and navigate bookmarks
- Allows bookmarks to be persisted
- When the cwd changes, if a stack has the same root_dir as the cwd, that stack will be loaded automatically
- **(NEW)** Bookmarks can have custom titles to help you remember the purpose of each bookmark

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
      mark_add_with_title = "<leader>mt",
      mark_remove = "<leader>mr",
      goto_next_mark = "]m",
      goto_prev_mark = "[m",
      open_mark_picker = "<leader>fm",
    },
    telescope = {
      n = {
        delete_mark = "d",
        clear_marks = "c",
        set_mark_title = "t",
        next_stack = "<Tab>",
        prev_stack = "<S-Tab>",
        new_stack = "N",
        rename_stack = "R",
        delete_stack = "D",
        -- open all marked files in current stack
        open_all_marked_files = "<C-o>", 
      },
    },
  },
  sign = {
    text = "",
    color = "#FF0000",
    --options: above || eol || eol_right_align || right_align || none
    -- If set to 'none', you can still assign a title to a mark.
    -- The title will only appear in Telescope but will not be shown as virt_text in the editor.
    title_position = "above"
  },
  --set to true to persist stacks and marks
  persist = true,

  --options: manual || auto
  --auto: When the cwd changes, if a stack has the same root_dir as the cwd, that stack will be loaded automatically
  --manual: manage stacks manually
  stack_mode = "auto",
}
```

## API

You can use the following APIs to customize your config

```lua
local stack = require("navimark.stack")
stack.mark_toggle()
stack.mark_add()
stack.mark_add_with_title()
stack.mark_remove()
stack.goto_next_mark()
stack.goto_prev_mark()

--root_dir is optional. If not provided, stack root_dir will be nil
stack.new_stack(name, root_dir)

-- dir is optional. If not provided, the cwd will be used as the root_dir.
-- If stack mode is set to auto, this enables autoloading
-- when the cwd matches the stack's root_dir.
-- or you can call :Navimark SaveRootDir to do the same function using cwd as root_dir.
stack.save_root_dir(dir)

local tele = require("navimark.tele")
tele.open_mark_picker()
```

## Tips

I highly recommend using my other plugin [proot.nvim](https://github.com/zongben/proot.nvim)

```lua
{
  "zongben/navimark.nvim",
  config = function()
    require("navimark").setup({
      persist = true,
      stack_mode = "auto",
    })
  end,
},
{
  "zongben/proot.nvim",
  config = function()
    require("proot").setup({
      events = {
        detected = function(name, path)
          local stack = require("navimark.stack")
          for _, s in ipairs(stack.stacks) do
             if s.root_dir == path then
               return
             end
          end
          stack.new_stack(name, path)
          stack.next_stack()
        end,
      },
    })
  end
}
```

With this config, whenever a new project is detected by proot, navimark will create a new stack with the project name and save its root directory.
When switching between projects, navimark will automatically load the corresponding stack based on the current working directory (cwd).

This combination makes it easy to manage bookmarks within each project.
Even when switching between different repositories, you can quickly access the bookmarks that belong to that specific project.
