local M = {}

M.defaults = {
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
        open_all_marked_files = "<C-o>",
      },
    },
  },
  sign = {
    text = "",
    color = "#FF0000",
    title_position = "above",
  },
  persist = true,
  stack_mode = "auto",
}

return M
