local M = {}

M.hello = function()
	print("Hello ")
end
M.clear = function()
	M._stack = {}
end
M.setup = function(opt)
	print("Hello World: ", opt)
end

local find_mapping = function(maps, lhs)
	-- pairs
	-- 		iterate over the keys of a table
	-- 		order is not guaranteed
	-- ipairs
	-- 		iterate over only numeric keys of a table
	-- 		order is guaranteed
	for _, v in ipairs(maps) do
		if v.lhs == lhs then
			return v
		end
	end
end

M._stack = {}
M.push = function(name, mode, mappings)
	-- if there exists a mapping for the current mode,
	-- then store it in the stack
	local maps = vim.api.nvim_get_keymap(mode)
	local existing_maps = {}
	for lhs, _ in pairs(mappings) do
		local existing = find_mapping(maps, lhs)
		if existing then
			existing_maps[lhs] = existing
		end
	end
	for lhs, rhs in pairs(mappings) do
		vim.keymap.set(mode, lhs, rhs)
	end
	M._stack[name] = M._stack[name] or {}
	M._stack[name][mode] = { existings = existing_maps, mappings = mappings }
end

M.pop = function(name, mode)
	local existing_stack = M._stack[name]
	M._stack[name] = nil
	if existing_stack and existing_stack[mode] then
		for lhs, _ in pairs(existing_stack[mode].mappings) do
			-- Keymap existings are be overridden by the push.
			local existing = existing_stack[mode].existings
			if existing[lhs] then
				local rhs = existing[lhs].rhs or existing[lhs].callback
				local desc = existing[lhs].desc
				vim.keymap.set(mode, lhs, rhs, { desc = desc })
			else
				vim.keymap.del(mode, lhs)
			end
		end
	end
end

return M
