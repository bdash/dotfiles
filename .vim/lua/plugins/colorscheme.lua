return {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd([[
	        colorscheme base16-classic-dark
	    ]])

        local base16_colors = require('base16-colorscheme').colors
        vim.api.nvim_set_hl(0, "SignColumn", { bg = base16_colors.base01 })
        vim.api.nvim_set_hl(0, "LineNr", { fg = base16_colors.base03, bg = base16_colors.base01 })
    end,
}

