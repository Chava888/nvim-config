-- ========================================================================
-- 📝 init.lua — Neovim Configuration
-- ========================================================================

-- =============================
-- 🌿 BASIC EDITOR SETTINGS
-- =============================
local opt = vim.opt

opt.number = true                 -- Show absolute line numbers
opt.relativenumber = true         -- Show relative line numbers
opt.tabstop = 2                   -- Number of spaces per <Tab>
opt.shiftwidth = 2                -- Indentation width
opt.expandtab = true              -- Convert tabs to spaces
opt.smartindent = true            -- Smart autoindenting
opt.wrap = false                  -- Disable line wrapping
opt.ignorecase = true             -- Ignore case when searching
opt.smartcase = true              -- Override ignorecase if uppercase in query
opt.hlsearch = false              -- Don’t highlight search matches
opt.incsearch = true              -- Incremental search
opt.clipboard = "unnamedplus"     -- Sync system clipboard
opt.termguicolors = true          -- Enable 24-bit color
opt.cursorline = true             -- Highlight current line

-- Medium cursor thickness in insert mode
vim.cmd("set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20")

-- =============================
-- ⚙️ BOOTSTRAP lazy.nvim
-- =============================
-- lazy.nvim is the plugin manager that handles plugin installation & updates.
-- If it’s not installed, this section automatically clones it.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================
-- 📦 PLUGINS
-- =============================
local plugins = {

  -- ----- 🎨 UI / Theme -----
  { "folke/tokyonight.nvim", name = "tokyonight", priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- ----- 🗂️ File Navigation -----
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- ----- 🌳 Syntax / Code Highlighting -----
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter" },

  -- ----- ⚙️ LSP / Language Support -----
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- ----- 🧠 Completion & Snippets -----
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- ----- 🔧 Editing Enhancements -----
  { "numToStr/Comment.nvim" },     -- "gcc" to toggle comments
  { "kylechui/nvim-surround" },    -- Add/change/delete surrounding characters
  { "windwp/nvim-autopairs" },     -- Auto-close brackets, quotes, etc.

  -- ----- 🧭 Git Integration -----
  { "lewis6991/gitsigns.nvim" },   -- Git hunk indicators & actions
  { "sindrets/diffview.nvim", dependencies = "nvim-lua/plenary.nvim" },

  -- ----- 🪲 Debugging -----
  { "mfussenegger/nvim-dap" },
}

require("lazy").setup(plugins, {})

-- =============================
-- 🎨 UI CONFIGURATION
-- =============================

-- Theme setup
require("tokyonight").setup({ style = "day" })
vim.cmd([[colorscheme tokyonight-day]])

-- Status line (bottom bar)
require("lualine").setup({
  options = {
    theme = "tokyonight",
    section_separators = "",
    component_separators = "",
  },
})

-- File explorer
require("nvim-tree").setup({
  view = { width = 35 },
  renderer = { highlight_opened_files = "name" },
})


-- =============================
-- 🧠 LSP (Language Servers)
-- =============================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "ruby_lsp", "gopls" },
  automatic_installation = true,
})

-- Use classic lspconfig API (still required for Mason)
local lspconfig = require("lspconfig")

-- Common keymaps when LSP attaches
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end

-- Capabilities for autocompletion
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- List of servers to configure
local servers = { "ruby_lsp", "gopls", "pyright", "lua_ls", "ts_ls", "rust_analyzer" }
for _, server in ipairs(servers) do
  lspconfig[server].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end


-- =============================
-- 🧩 COMPLETION (nvim-cmp)
-- =============================
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),

    -- Smart Tab completion / snippet jumping
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- =============================
-- 🔧 OTHER PLUGIN CONFIGS
-- =============================
require("Comment").setup()
require("nvim-surround").setup()
require("nvim-autopairs").setup()
require("gitsigns").setup()

-- =============================
-- 🪄 KEYMAPS
-- =============================

-- Leader key (space)
vim.g.mapleader = " "

-- ----- File explorer & search -----
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })

-- ----- Git -----
vim.keymap.set("n", "]c", function() require("gitsigns").next_hunk() end, { desc = "Next hunk" })
vim.keymap.set("n", "[c", function() require("gitsigns").prev_hunk() end, { desc = "Prev hunk" })
vim.keymap.set("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Open diff view" })
vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "File history" })
vim.keymap.set("n", "<leader>gc", ":DiffviewClose<CR>", { desc = "Close diff view" })
vim.keymap.set("n", "<leader>gb", function() require("gitsigns").blame_line() end, { desc = "Blame line" })

-- ----- Window navigation -----
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- ----- Indenting -----
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- ----- Move lines -----
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- =============================
-- 🔁 AUTO-RELOAD CONFIG ON SAVE
-- =============================
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  command = "source <afile>",
})

-- ========================================================================
-- ✅ END OF CONFIG
-- Notes:
-- - Plugins are managed by lazy.nvim → edit plugin list near the top.
-- - LSP settings → see the “🧠 LSP” section.
-- - Keymaps are grouped by purpose under “🪄 KEYMAPS”.
-- ========================================================================
