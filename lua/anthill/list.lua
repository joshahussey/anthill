local xmlreader = require("xmlreader")
local root_markers = { "build.xml" }
local root_dir = require("jdtls.setup").find_root(root_markers)
local M = {}
if root_dir == nil then
	M.info = {}
	M.info_count = 0
	return M
end
if root_dir == "" then
	M.info = {}
	M.info_count = 0
	return M
end
function File_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local build_file_path = root_dir .. "/build.xml"
function Get_build_list_info()
	local info = {}
	local idx = 1
	local r = assert(xmlreader.from_file(build_file_path))
	while r:read() do
		if r:node_type() ~= "end element" then
			if r:name() == "target" then
				local name
				local description
				local depends
				local isAttribute = r:move_to_first_attribute()
				while isAttribute do
					print(r:local_name())
					local attribute = r:local_name()
					if attribute == "name" then
						name = r:value()
						print(name)
					end
					if attribute == "description" then
						description = r:value()
						print(description)
					end
					if attribute == "depends" then
						depends = r:value()
					end
					isAttribute = r:move_to_next_attribute()
				end
				if name == nil then
					print("name is nil")
				end
				if description == nil then
					print("description is nil")
				end
				if depends == nil then
					print("depends is nil")
				end
				info[idx] = { name = name, description = description, depends = depends }
				idx = idx + 1
			end
		end
	end
	return info, idx
end

if not File_exists(build_file_path) then
	M.info = {}
	M.info_count = 0
	return M
end
if M.info == nil then
	M.info, M.info_count = Get_build_list_info()
end
return M
