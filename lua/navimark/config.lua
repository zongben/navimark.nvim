local M = {}

M.defaults = {
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
        open_all_marked_files = "<C-o>",
      },
    },
  },
  sign = {
    text = "",
    color = "#FF0000",
  },
  persist = false,
  stack_mode = "manual",
}

return M
