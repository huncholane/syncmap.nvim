local M = {
	opts = require("syncmap.default"),
}
local state = require("syncmap.state")

function M.setup()
	vim.api.nvim_create_user_command("Syncmap", function(args)
		local arg = args.args
		if arg == "restart" then
			state.restart()
		elseif arg == "clean" then
			state.clean()
		elseif arg == "active" then
			state.show_active()
		elseif arg == "opts" then
			state.show_opts()
		else
			vim.notify("Unknown Syncmap command: " .. arg, vim.log.levels.ERROR)
		end
	end, {
		desc = "Syncmap control command",
		nargs = 1,
		complete = function()
			return { "restart", "clean", "active", "opts" }
		end,
	})
end

return M
