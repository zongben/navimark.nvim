local M = {}

M.defaults = {
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

return M
