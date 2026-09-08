# a folder containing init.lua is treated as a ModuleScript.
# otherwise, it is treated as a normal Folder.

"""
Project: Scan source files -> Build a virtual ModuleScript tree
↓
Store module factories as:
Modules[instance] = function(script, require)
    ...
end
↓
Rewrite relative requires:
require("./creator")
→ require(script.Parent.creator)
↓
Generate a single Lua file
↓
Recreate the ModuleScript tree at runtime
↓
Override require():
require(instance)
→ Modules[instance]
→ Execute module
↓
Cache result
↓
Return module exports
"""

import re
import sys
from pathlib import Path


requirePattern = re.compile(r'require\s*\(\s*["\']([^"\']+)["\']\s*\)')


def convertRelativeRequire(path: str) -> str:
    if not (path.startswith("./") or path.startswith("../")):
        return None

    result = ["script", "Parent"]

    while path.startswith("../"):
        result.append("Parent")
        path = path[3:]

    if path.startswith("./"):
        path = path[2:]

    for part in path.split("/"):
        if part:
            result.append(part)

    return ".".join(result)


def rewriteRequires(source: str) -> str:
    def replacer(match):
        path = match.group(1)
        resolved = convertRelativeRequire(path)

        if resolved is None:
            return match.group(0)

        return f"require({resolved})"

    return requirePattern.sub(replacer, source)


args = {}

for arg in sys.argv[1:]:
    if "=" in arg:
        key, value = arg.split("=", 1)
        args[key] = value


name = args.get("name", "Project")
inputPath = args.get("input", "src")
outputPath = args.get("output", "main.luau")

sourceExtensions = {
    ".lua",
    ".luau",
}

tree = {}
varId = 0

content = f"""--[[
{name} folder tree:
"""


def nextVar():
    global varId
    varId += 1
    return f"v{varId}"


def buildTree(folder):
    tree = {}

    global content

    for item in sorted(Path(folder).iterdir()):
        if item.is_dir():
            content += f"Folder: {item.name}\n"

            tree[nextVar()] = [
                "Folder",
                item.name,
                buildTree(item),
                f"Folder: {item.name}",
            ]

        elif item.suffix in sourceExtensions:
            content += f"{folder}\\{item.stem}\n"

            tree[nextVar()] = [
                "ModuleScript",
                item.stem,
                item.read_text(encoding="utf-8"),
                f"{folder}\\{item.stem}\n",
            ]

    return tree


tree = buildTree(inputPath)

content += f"""]]

local Modules = {{}}
local {name} = Instance.new("ModuleScript")
{name}.Name = "{name}"

"""


def generateSource(source):
    source = rewriteRequires(source)
    source = "\n".join("    " + line for line in source.splitlines())

    return f"""function(script, require)
{source}
end
"""


def generateMap(tree, parent):
    global content

    for file, source in tree.items():
        content += f"-- {source[3]}"

        if source[0] == "Folder":
            kind = (
                "ModuleScript"
                if any(child[1] == "init" for child in source[2].values())
                else "Folder"
            )

            content += f'\nlocal {file} = Instance.new("{kind}", {parent})\n'
            content += f'{file}.Name = "{source[1]}"\n\n'

            generateMap(source[2], file)

        else:
            if source[1] == "init":
                content += f"\nModules[{parent}] = {generateSource(source[2])}\n"

            else:
                content += f"local {file} = Instance.new('ModuleScript', {parent})\n"
                content += f'{file}.Name = "{source[1]}"\n'
                content += f"\nModules[{file}] = {generateSource(source[2])}\n"


generateMap(tree, name)

content += f"""local Cache = {{}}
local Loading = {{}}
local OldRequire = require

function Require(target)
    if Modules[target] ~= nil then
        if Cache[target] == Loading then
            error("Circular require detected: " .. target:GetFullName())
        end

        if Cache[target] ~= nil then
            return Cache[target]
        end

        Cache[target] = Loading

        local factory = Modules[target]
        local result = factory(target, Require)

        if result == nil then
            error("ModuleScript '" .. target:GetFullName() .. "' did not return exactly one value", 2)
        end

        Cache[target] = result

        return result
    end

    return OldRequire(target)
end

return Require({name})
"""


Path(outputPath).write_text(content, encoding="utf-8")
