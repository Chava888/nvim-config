-- ========================================================================
-- 📝 init.lua — Neovim Configuration
-- ========================================================================

-- =============================
-- 🌿 BASIC EDITOR SETTINGS
-- =============================
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.signcolumn = "yes"

-- Medium cursor thickness in insert mode
vim.cmd("set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20")

-- =============================
-- ⚙️ BOOTSTRAP lazy.nvim
-- =============================
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

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
  { "numToStr/Comment.nvim" },
  { "kylechui/nvim-surround" },
  { "windwp/nvim-autopairs" },

  -- ----- 🧭 Git Integration -----
  { "lewis6991/gitsigns.nvim" },
  { "sindrets/diffview.nvim" },

  -- ----- 💎 Ruby / Rails -----
  { "tpope/vim-rails" },

  -- ----- 🧪 Testing -----
  { "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "olimorris/neotest-rspec",
    },
  },

  -- ----- 🖥️ Terminal -----
  { "akinsho/toggleterm.nvim" },
}

require("lazy").setup(plugins, {})

-- =============================
-- 🎨 UI CONFIGURATION
-- =============================

require("tokyonight").setup({ style = "night" })
vim.cmd([[colorscheme tokyonight-night]])

require("telescope").setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
    },
  },
})
require("telescope").load_extension("fzf")

require("lualine").setup({
  options = {
    theme = "tokyonight",
    section_separators = "",
    component_separators = "",
  },
})

require("nvim-tree").setup({
  sync_root_with_cwd = true,
  view = { width = 35 },
  renderer = { highlight_opened_files = "name" },
})


-- =============================
-- 🧠 LSP (Language Servers)
-- =============================
local servers = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "ruby_lsp", "gopls" }

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
})

local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in ipairs(servers) do
  lspconfig[server].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
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
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
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

require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "typescript", "javascript", "rust", "go", "ruby" },
  highlight = { enable = true },
  indent = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
})

require("toggleterm").setup({
  size = 20,
  open_mapping = [[<C-\>]],
  direction = "horizontal",
  shade_terminals = true,
})

require("neotest").setup({
  adapters = {
    require("neotest-rspec"),
  },
})

-- =============================
-- 🪄 KEYMAPS
-- =============================

-- ----- File explorer & search -----
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Search text in all files" })
vim.keymap.set("n", "<leader>fw", ":Telescope grep_string<CR>", { desc = "Search word under cursor" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find open buffers" })

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
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- ----- Window management / Split views -----
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })
vim.keymap.set("n", "<leader>so", ":only<CR>", { desc = "Close all other splits" })

-- Resize splits
vim.keymap.set("n", "<leader>+", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<leader>-", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<leader>>", ":vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<leader><", ":vertical resize -2<CR>", { desc = "Decrease window width" })

-- Equal split sizes
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Make splits equal size" })

-- ----- Indenting -----
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- ----- Move lines -----
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- ----- Terminal -----
vim.keymap.set("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ----- Rails -----
vim.keymap.set("n", "<leader>ra", ":A<CR>", { desc = "Alternate file (e.g. model ↔ spec)" })
vim.keymap.set("n", "<leader>rr", ":R<CR>", { desc = "Related file" })

-- ----- Tests -----
vim.keymap.set("n", "<leader>tn", function() require("neotest").run.run() end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run test file" })
vim.keymap.set("n", "<leader>to", function() require("neotest").output.open() end, { desc = "Open test output" })
vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })

-- =============================
-- 🔁 AUTO-RELOAD CONFIG ON SAVE
-- =============================
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  command = "source <afile>",
})
