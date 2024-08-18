return {
    "tinted-theming/base16-vim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd([[
            " Tell the color scheme that our shell is using the base16 colorspace
            " so it can work around that. Failing to do that will result in some
            " colors being wildly wrong.
	        let base16colorspace=256

	        colorscheme base16-default-dark
	    ]])
    end,
}
