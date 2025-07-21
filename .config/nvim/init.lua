-- This is futurewise.lat nvim config. Keep it simple in one file
-- So LLMs can interact easily

vim.opt.nu = true              -- enable line numbers
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
            { out,                            "WarningMsg" },
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
        -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
        {
            "folke/tokyonight.nvim",
            lazy = false, -- Load the plugin immediately
            priority = 1000, -- Ensures it's loaded before other plugins
            config = function()
                vim.cmd([[colorscheme tokyonight-moon]])
                -- Optional: additional configuration, e.g., style variants
                -- vim.g.tokyonight_style = "storm"  -- options: "storm", "night", "day"
            end,
        },
        {
            'nvim-telescope/telescope.nvim', tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' }
        },
        { 'nvim-treesitter/nvim-treesitter', build = ":TSUpdate" },
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
            -- optional for floating window border decoration
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            {
                "williamboman/mason.nvim"
            },
            { "williamboman/mason-lspconfig.nvim" },
            { "neovim/nvim-lspconfig", }
            -- setting the keybinding for LazyGit with 'keys' is recommended in
            -- order to load the plugin when the command is run for the first time
            --      keys = {
            --          { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
            --      }
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

-- mason lsp
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "svelte" }
})
local lspConfig = require("lspconfig")
lspConfig.svelte.setup({})
lspConfig.lua_ls.setup({})

local builtin = require("telescope.builtin")

-- KEYMAPS
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<C-o>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle<cr>')
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>')
-- In terminal mode, remap to normal mode
vim.keymap.set('t', '<C-g>', '<C-\\><C-n>', { noremap = true, silent = true })
-- lsp
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})

-- LSP Formatting Keymap
vim.keymap.set('n', '<Leader>f', function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format current file with LSP" })

-- vim.cmd.colorscheme "catppuccin"

-- for TS
local config = require("nvim-treesitter.configs")
config.setup({
    ensure_installed = { "lua", "javascript", "svelte", "python", "gitignore", "dockerfile", "typescript", "toml", "markdown", "php", "bash" },
    highlight = { enable = true },
    indent = { enable = true },
})

-- Auto-format on save for LSP-enabled filetypes
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
    pattern = { "*.svelte", "*.ts", "*.js" }, -- Adjust patterns if needed for other file types
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
    desc = "Format file before saving with LSP",
})
