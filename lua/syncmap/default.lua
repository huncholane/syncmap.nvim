local expand = vim.fn.expand

---@type FinalSyncmapOpts
return {
	map = {
		{ expand("~/.dotfiles/nvim/"), expand("~/.config/nvim/") },
	},
	reverse_sync_on_startup = true,
	rsync = { "-a", "--delete" },
	log_level = "error",
}
