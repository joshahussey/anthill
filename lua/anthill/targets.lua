local xmlreader = require('xmlreader')
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle," }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
    return
end
local build_file_path = root_dir .. "/build.xml"
function Get_targets()
    local targets = {}
    local idx = 1
    local r = assert(xmlreader.from_file(build_file_path))
    while (r:read()) do
        if (r:node_type() ~= 'end element') then
            if (r:name() == 'target') then
                targets[idx] = r:get_attribute('name')
                idx = idx + 1
            end
        end
    end
    return targets, idx
end
local M = {}
local targets, target_count = Get_targets()
M.targets = targets
M.target_count = target_count
return M
