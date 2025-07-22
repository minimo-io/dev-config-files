-- This is futurewise.lat nvim config. Keep it simple in one file
-- so LLMs can interact easily

vim.opt.nu = true  -- enable line numbers
vim.opt.relativenumber = false -- relative line numbers

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
      "folke/tokyonight.nvim",
      lazy = false,         -- Load the plugin immediately
      priority = 1000,      -- Ensures it's loaded before other plugins
      config = function()
        vim.cmd([[colorscheme tokyonight-moon]])
      end,
    },    
    {
      'nvim-telescope/telescope.nvim', 
      tag = '0.1.8', 
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    { 
      'nvim-treesitter/nvim-treesitter', 
      build = ":TSUpdate" 
    },
    -- LSP and completion plugins
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    -- Completion engine
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    -- Snippet engine (required for nvim-cmp)
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },
    {
      "kdheepak/lazygit.nvim",
      lazy = true,
      cmd = {
          "LazyGit",
          "LazyGitConfig",
          "LazyGitCurrentFile",
          "LazyGitFilter",
          "LazyGitFilterCurrentFile",
      },
      dependencies = {
          "nvim-lua/plenary.nvim",
      },
    },
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      config = function()
        require("nvim-tree").setup {}
      end,
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

require("tokyonight").setup()

-- mason lsp setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { 
    "lua_ls", 
    "svelte", 
    "eslint",
    "pyright",        -- Python LSP
    "ts_ls",          -- TypeScript/JavaScript LSP
  }
})

-- Setup completion
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Setup LSP servers with enhanced capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require("lspconfig")

lspconfig.svelte.setup({
  capabilities = capabilities,
})

lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})

lspconfig.eslint.setup({
  capabilities = capabilities,
})

lspconfig.pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true
      }
    }
  }
})

lspconfig.ts_ls.setup({
  capabilities = capabilities,
})

local builtin = require("telescope.builtin")

-- KEYMAPS
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<C-o>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle<cr>')
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>')
-- In terminal mode, remap to normal mode
vim.keymap.set('t', '<C-g>', '<C-\\><C-n>', { noremap = true, silent = true })

-- LSP keymaps
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {})

-- LSP formatting keymap
vim.keymap.set('n', '<Leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format current file with LSP" })

-- Treesitter setup
local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {"lua", "javascript", "svelte", "python", "gitignore", "dockerfile", "typescript", "toml", "markdown", "php", "bash"},
  highlight = { enable = true },
  indent = { enable = true },
})

-- Auto-format on save for LSP-enabled filetypes
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
  pattern = { "*.svelte", "*.ts", "*.js", "*.py" }, -- Added Python files
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
  desc = "Format file before saving with LSP",
})