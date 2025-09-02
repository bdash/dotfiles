return {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v4.x",
    config = function()
        local cmp = require("cmp")
        local lspconfig = require("lspconfig")
        local lsp_zero = require("lsp-zero")

        lsp_zero.on_attach(function(event, bufnr)
            -- Use lsp-zero's default keymaps. They seem fine.
            -- https://lsp-zero.netlify.app/v4.x/language-server-configuration.html
            lsp_zero.default_keymaps({ buffer = bufnr })
            local opts = { buffer = event.buf }

            vim.keymap.set({ 'n', 'x' }, '<leader>cf', function()
                vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
            end, opts)
            vim.keymap.set({ 'n', 'x' }, '<leader>d', vim.diagnostic.open_float)
        end)

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { 'rust_analyzer', 'clangd', 'lua_ls', 'ruff', 'basedpyright' },
            handlers = {
                lsp_zero.default_setup,
                lua_ls = function()
                    -- Configure Lua support only for Neovim's sake.
                    lspconfig.lua_ls.setup(lsp_zero.nvim_lua_ls())
                end,
                basedpyright = function()
                    lspconfig.basedpyright.setup({
                        settings = {
                            basedpyright = {
                                -- basedpyright enables strict type checking by default.
                                -- Most random python code won't support that.
                                analysis = { typeCheckingMode = "off" },
                            }
                        }
                    })
                end,
            },
        })

        local cmp_format = lsp_zero.cmp_format({ details = true })
        cmp.setup({
            sources = { { name = "nvim_lsp" }, { name = "nvim_lua" }, { name = "buffer" }, },
            mapping = {
                ["<cr>"] = cmp.mapping.confirm({
                    -- Don't auto-select the first item on enter as it makes
                    -- writing comments painful.
                    select = false,
                }),
                -- Tab selects first completion if none is selected.
                -- A second press will confirm the completion.
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        local entry = cmp.get_selected_entry()
                        if not entry then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            cmp.confirm()
                        end
                    else
                        fallback()
                    end
                end, { "i", "s", "c" }),
            },
            formatting = cmp_format,
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },

        })

        -- Offer path-based suggestions for : commands
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            }),
            matching = { disallow_symbol_nonprefix_matching = false }
        })


        vim.diagnostic.config({
            severity_sort = true,
            underline = false,
            update_in_insert = true,
        })
    end,
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-path",
        "hrsh7th/nvim-cmp",
        "neovim/nvim-lspconfig",
        "williamboman/mason-lspconfig.nvim",
        "williamboman/mason.nvim",
    },
}
