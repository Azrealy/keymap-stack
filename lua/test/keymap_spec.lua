---@diagnostic disable: undefined-global
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
describe("keymap-stack", function()
	it("loads keymap-stack package successfully", function()
		require("keymap-stack")
	end)

	it("can push a single mapping", function()
		local stack = require("keymap-stack")
		stack.push("debug_mode", "n", { test = "echo 'this is test'" })
		local maps = vim.api.nvim_get_keymap("n")
		local found = find_mapping(maps, "test")
		assert.are.same("echo 'this is test'", found.rhs)
	end)

	it("can pop a single mapping", function()
		local stack = require("keymap-stack")
		local pre_rhs = "echo 'inital keymap'"
		local after_rhs = "echo 'after keymap'"
		stack.push("debug_mode", "n", { test = pre_rhs })
		stack.push("debug_mode", "n", { test = after_rhs })
		stack.pop("debug_mode", "n")
		local maps = vim.api.nvim_get_keymap("n")
		local found = find_mapping(maps, "test")
		assert.are.same(pre_rhs, found.rhs)
	end)

	it("can push a mutlti mapping", function()
		local rhs = "echo 'this is test'"
		local stack = require("keymap-stack")
		stack.push("debug_mode", "n", { ["test_m_1"] = rhs .. 1, ["test_m_2"] = rhs .. 2 })
		local maps = vim.api.nvim_get_keymap("n")
		local found_1 = find_mapping(maps, "test_m_1")
		assert.are.same(rhs .. "1", found_1.rhs)

		local found_2 = find_mapping(maps, "test_m_2")
		assert.are.same(rhs .. "2", found_2.rhs)
	end)
end)
