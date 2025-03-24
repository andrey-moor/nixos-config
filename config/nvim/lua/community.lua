-- nvim/lua/community.lua
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.editing-support.copilotchat-nvim" },
  { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  { import = "astrocommunity.quickfix.quicker-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.pack.full-dadbod" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
}
