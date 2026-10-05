-- opts
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes:1"
vim.o.cursorline = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.scrolloff = 10
vim.o.list = true
vim.o.listchars = "trail:·,tab:  "
vim.o.winborder = "rounded"
vim.o.termguicolors = true
vim.o.showmode = false

-- keymaps
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr><esc>")
vim.keymap.set("n", "<leader>re", "<cmd>w<cr><cmd>restart<cr>")
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set("v", "<leader>/", "gc", { remap = true })
vim.keymap.set("n", "<leader>/", "gcc", { remap = true })

vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>")
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ lsp_format = "fallback", timeout_ms = 500 })
end)
vim.keymap.set("n", "-", "<cmd>Oil --float<cr>")

-- commands
vim.api.nvim_create_user_command("PackDel", function()
	local plugins = vim.iter(vim.pack.get())
		:filter(function(p)
			return not p.active
		end)
		:map(function(p)
			return p.spec.name
		end)
		:totable()

	if #plugins == 0 then
		vim.notify("Nothing to delete")
		return
	end

	local message = "Delete unused plugins: " .. table.concat(plugins, ", ")
	if vim.fn.confirm(message, "&Yes\n&No", 2) == 1 then
		vim.pack.del(plugins)
	end
	vim.notify("Deleted plugins: " .. table.concat(plugins, ", "))
end, { desc = "Delete unused plugins" })

-- built-in visuals
vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 2 },
	signs = false,
	severity_sort = true,
	update_in_insert = false,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight on yank",
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
	end,
})

-- plugin installation
vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.x") },
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/nvim-mini/mini.surround",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/brenoprata10/nvim-highlight-colors",
	"https://github.com/wakatime/vim-wakatime",
})

-- theme
require("catppuccin").setup({
	flavour = "auto",
	transparent_background = true,
	no_italic = true,
})

vim.cmd.colorscheme("catppuccin-nvim")

-- lsp
require("mason").setup()
require("mason-lspconfig").setup()

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("ts_ls", {
	init_options = {
		preferences = {
			autoImportFileExcludePatterns = { "**/node_modules/**" },
		},
	},
})

vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
			},
		},
	},
})

-- treesitter
local ensure_installed = {
	"lua",
	"markdown",
	"html",
	"css",
	"javascript",
	"typescript",
	"tsx",
	"python",
	"typst",
}
local installed = require("nvim-treesitter.config").get_installed()
local missing = vim.tbl_filter(function(p)
	return not vim.list_contains(installed, p)
end, ensure_installed)
if #missing > 0 then
	require("nvim-treesitter").install(missing)
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "Treesitter highlight and indent",
	group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true }),
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(args.match)
		if not lang then
			return
		end

		pcall(vim.treesitter.start, args.buf, lang)

		if vim.treesitter.query.get(lang, "indents") then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- completion
require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	cmdline = {
		keymap = { preset = "inherit" },
		completion = {
			menu = {
				auto_show = true,
			},
		},
	},
	signature = {
		enabled = true,
		trigger = {
			show_on_insert = true,
			show_on_keyword = true,
		},
	},
})

-- formatting
require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		python = { "ruff_format" },
	},
})

-- navigation
require("oil").setup({
	delete_to_trash = true,
	view_options = {
		show_hidden = true,
	},
})

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			n = {
				["g?"] = "which_key",
			},
		},
	},
	pickers = {
		find_files = {
			hidden = true,
		},
		buffers = {
			mappings = {
				i = { ["<C-d>"] = actions.delete_buffer },
				n = { ["<C-d>"] = actions.delete_buffer },
			},
		},
		lsp_definitions = {
			show_line = false,
		},
		lsp_references = {
			show_line = false,
		},
	},
})
require("telescope").load_extension("fzf")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions, { desc = "Definitions" })
vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "References" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })

-- git
local gs = require("gitsigns")
gs.setup({
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text_pos = "eol",
		delay = 300,
	},
})

vim.keymap.set("n", "<leader>hr", gs.reset_hunk)
vim.keymap.set("v", "<leader>hr", function()
	gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end)

-- dx
require("nvim-autopairs").setup({})
require("mini.surround").setup({})

-- visuals
require("lualine").setup({
	sections = {
		lualine_b = { "branch", "diagnostics" },
		lualine_x = { "filetype" },
	},
	tabline = {
		lualine_a = {
			{
				"buffers",
				mode = 4,
				section_separators = { left = "", right = "" },
			},
		},
	},
})
require("nvim-highlight-colors").setup({})
