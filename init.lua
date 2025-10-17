-- Basic editor settings
vim.opt.number = true          -- Line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.tabstop = 2           -- Tab width
vim.opt.shiftwidth = 2        -- Indent width
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.smartindent = true    -- Smart indenting
vim.opt.wrap = false          -- Don't wrap lines
vim.opt.ignorecase = true     -- Case insensitive search
vim.opt.smartcase = true      -- Case sensitive if uppercase used
vim.opt.hlsearch = false      -- Don't highlight search results
vim.opt.incsearch = true      -- Incremental search

-- =====================================
-- Bootstrap lazy.nvim
-- =====================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {}
local plugins ={
  -- Theme
  { "folke/tokyonight.nvim", name = "tokyonight", priority = 1000 },
  
  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  
  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  
  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  
  -- Git integration
  { "lewis6991/gitsigns.nvim" },

  -- Git diff viewer
  { "sindrets/diffview.nvim", dependencies = "nvim-lua/plenary.nvim" },

  -- Status line
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- LSP (Language Server Protocol) for code intelligence
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },           -- LSP installer
  { "williamboman/mason-lspconfig.nvim" }, -- Bridge between mason & lspconfig

  -- Autocompletion
  { "hrsh7th/nvim-cmp" },         -- Completion engine
  { "hrsh7th/cmp-nvim-lsp" },     -- LSP completions
  { "hrsh7th/cmp-buffer" },       -- Buffer completions
  { "hrsh7th/cmp-path" },         -- Path completions
  { "L3MON4D3/LuaSnip" },         -- Snippet engine
  { "saadparwaiz1/cmp_luasnip" }, -- Snippet completions

  -- Auto pairs (auto-close brackets, quotes)
  { "windwp/nvim-autopairs" },

  -- Comments (gcc to comment/uncomment)
  { "numToStr/Comment.nvim" },

  -- Surround text with quotes, brackets, etc
  { "kylechui/nvim-surround" },

  -- Better syntax highlighting
  { "nvim-treesitter/nvim-treesitter-textobjects" },

  -- Debugging
  { "mfussenegger/nvim-dap" }
}

-- Configure and load plugins
require("lazy").setup(plugins,opts)

-- Configure tokyonight theme with day style
require("tokyonight").setup({style = "day"})

-- Apply the colorscheme
vim.cmd [[colorscheme tokyonight-day]]

-- Configure nvim-tree
require("nvim-tree").setup()

-- Configure LSP
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "ruby_lsp", "gopls" },
  automatic_installation = true
})

-- Setup ruby-lsp when it's available
require("lspconfig").ruby_lsp.setup({})

-- Setup Go LSP
require("lspconfig").gopls.setup({})

-- Setup Python LSP
require("lspconfig").pyright.setup({})

-- Setup Lua LSP
require("lspconfig").lua_ls.setup({})

-- Setup TypeScript/JavaScript LSP
require("lspconfig").ts_ls.setup({})

-- Setup Rust LSP
require("lspconfig").rust_analyzer.setup({})

-- Configure completion
require("cmp").setup({})

-- Configure other plugins
require("Comment").setup()
require("nvim-surround").setup()
require("nvim-autopairs").setup()

-- Configure gitsigns
require('gitsigns').setup()

-- Gitsigns key mappings
vim.keymap.set("n", "]c", function() require("gitsigns").next_hunk() end)
vim.keymap.set("n", "[c", function() require("gitsigns").prev_hunk() end)
vim.keymap.set("n", "<leader>gs", function() require("gitsigns").stage_hunk() end)
vim.keymap.set("n", "<leader>gr", function() require("gitsigns").reset_hunk() end)

-- Set leader key
vim.g.mapleader = " "

-- Key mappings
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")  -- Toggle file explorer
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")  -- Find files

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")  -- Move to left window
vim.keymap.set("n", "<C-j>", "<C-w>j")  -- Move to bottom window  
vim.keymap.set("n", "<C-k>", "<C-w>k")  -- Move to top window
vim.keymap.set("n", "<C-l>", "<C-w>l")  -- Move to right window

-- Better indenting
vim.keymap.set("v", "<", "<gv")         -- Keep selection after indent
vim.keymap.set("v", ">", ">gv")         -- Keep selection after indent

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")     -- Move line down
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")     -- Move line up

-- Sync clipboard with system
vim.opt.clipboard = "unnamedplus"

-- Auto-reload init.lua on save
vim.cmd([[
  augroup ReloadConfig
    autocmd!
    autocmd BufWritePost init.lua source <afile>
  augroup END
]])