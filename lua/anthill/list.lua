local xmlreader = require("xmlreader")
local root_markers = { "build.xml" }
local function find_root(markers)
    local dirname = vim.fs.dirname(vim.fs.find(markers, {path = vim.fn.getcwd(), upward=true})[1])
    return dirname
end
local function get_build_file_path()
    local root = find_root(root_markers)
    print(root)
    local path = ''
    if not (root == nil) then
        path = root .. "/build.xml"
    end
    print(path)
    return path
end
local M = {}
function M.File_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end
function M.Get_build_list_info()
    local path = get_build_file_path()
	local info = {}
	local targets = {}
	local idx = 1
	local r = assert(xmlreader.from_file(path))
	while r:read() do
		if r:node_type() ~= "end element" then
			if r:name() == "target" then
				local name
				local description
				local depends
				local isAttribute = r:move_to_first_attribute()
				while isAttribute do
					local attribute = r:local_name()
					if attribute == "name" then
						name = r:value()
					end
					if attribute == "description" then
						description = r:value()
					end
					if attribute == "depends" then
						depends = r:value()
					end
					isAttribute = r:move_to_next_attribute()
				end
				if description == nil then
					description = name
				end
				if depends == nil then
					depends = "None"
				end
				targets[idx] = name
				info[idx] = { description = description, depends = depends, line_number = r:line_number() }
				idx = idx + 1
			end
		end
	end
	return targets, idx, info
end
function M.update()
    M.build_file_path = get_build_file_path()
    M.targets, M.target_count, M.info = M.Get_build_list_info()
    return M.build_file_path, M.targets, M.target_count, M.info
end
return M
