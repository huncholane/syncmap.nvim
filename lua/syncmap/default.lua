local expand = vim.fn.expand

---@type FinalSyncmapOpts
return {
	map = {},
	reverse_sync_on_startup = true,
	rsync = { "-a", "--delete" },
	log_level = "error",
}
