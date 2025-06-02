---A file or folder to use with rsync
---Keep in mind that slash matters. A final slash means to use the contents so you most likely want to use slashes at the end of folders.
---
---A file or folder to use with rsync.
---⚠️ A trailing slash means \"sync the contents\" — without it, rsync syncs the whole folder.
---You usually want a slash at the end (e.g., `"~/.dotfiles/nvim/"`)
---@class RsyncPath : string

---@alias ReverseSyncOnSpawn boolean @[default=true]

---@alias RsyncFlag
---| "-a"        # archive: preserve everything
---| "--delete" # delete files not in source
---| "-v"       # verbose output
---| "-z"       # compress during transfer
---| "--dry-run" # simulate the sync
---| string     # allow custom flags too

---@alias LogLevel
---| "info" show info logs
---| "error" show error logs
---| "none" show no logs

---Ex: `--exclude-from='.gitignore'`
---@alias ExcludeFrom string @[default=".gitignore"] Adds --exclude-from in rsync

---A match to use for syncing using files or folders.
---
---Ex: `{"~/.dotfiles/nvim/", "~/.config/nvim/"}` sync everything within `~/.dotfiles/nvim/` into `~/.config/nvim/`
---@class SyncmapConfigMatch
---@field [1] RsyncPath @[required] Path to sync from
---@field [2] RsyncPath @[required] Path to sync to
---@field reverse_sync_on_spawn? ReverseSyncOnSpawn @[default=parent.reverse_sync_on_startup]
---@field rsync? RsyncFlag[] @[default=parent.rsync] Flags to use with rsync
---@field exclude_from? ExcludeFrom @[default=parent.exclude_from]

---Configurations for syncmap
---@class SyncmapOpts
---@field map? SyncmapConfigMatch[] @[default=~/.dotfiles/nvim/ ~/.config/nvim/] The folders and files to keep synchronized
---@field reverse_sync_on_startup? ReverseSyncOnSpawn
---@field rsync? RsyncFlag[] @[default={"-a", "--delete"}] Rsync flags that will be used if a map item doesn't include anything. I.E. Default flags
---@field log_level? LogLevel @[default="error"] Sets the log level for syncmap
---@field exclude_from? ExcludeFrom

---Final config
---@class FinalSyncmapOpts
---@field map SyncmapConfigMatch[] @[default=~/.dotfiles/nvim/ ~/.config/nvim] The folders and files to keep synchronized
---@field reverse_sync_on_startup ReverseSyncOnSpawn
---@field rsync RsyncFlag[] @[default={"-a", "--delete"}] Rsync flags that will be used if a map item doesn't include anything. I.E. Default flags
---@field log_level LogLevel @[default="error"] Sets the log level for syncmap
---@field exclude_from? ExcludeFrom

---Parameters pased into rsync methods
---@class RsyncParams
---@field src RsyncPath Source path to sync from
---@field dst RsyncPath Destination path to sync from
---@field flags? RsyncFlag[] @[default={}] Flags used while running rsync. Default to {} for safety precautions.
---@field reverse_sync_on_spawn ReverseSyncOnSpawn
