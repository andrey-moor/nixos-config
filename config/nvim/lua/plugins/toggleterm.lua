return {
  "akinsho/toggleterm.nvim",
  opts = {
    open_mapping = [[<C-\>]],
    direction = "float", -- Change this to "horizontal", "vertical", or "tab" if preferred
    float_opts = {
      border = "curved",
    },
    -- Add this to disable floating window for git editor
    on_create = function(term)
      if vim.bo[term.bufnr].filetype == "gitcommit" or vim.bo[term.bufnr].filetype == "gitrebase" then
        vim.api.nvim_win_set_config(term.window, { relative = "" }) -- Makes it a regular window/buffer
      end
    end,
  },
}
