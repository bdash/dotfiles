return {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd([[
            " Tell the color scheme that our shell is using the base16 colorspace
            " so it can work around that. Failing to do that will result in some
            " colors being wildly wrong.
	        let base16colorspace=256

	        colorscheme base16-classic-dark
	    ]])

        local base16_colors = require('base16-colorscheme').colors
        vim.api.nvim_set_hl(0, "SignColumn", { bg = base16_colors.base01 })
        vim.api.nvim_set_hl(0, "LineNr", { fg = base16_colors.base03, bg = base16_colors.base01 })
    end,
}

