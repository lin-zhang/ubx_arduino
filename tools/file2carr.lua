#!/usr/bin/env luajit

---
--- Convert the contents of a file to a C-struct representation. The
--- data is \0 terminated.
---

local utils=require "utils"

function filename(path)
   local t=utils.split(path, '/')
   return t[#t]
end

if #arg < 1 then
   print(arg[0]..": convert file contents to a C array")
   print("usage: "..arg[0].." <file> <array name>")
   os.exit(1)
end

outfile=arg[1]..".hexarr"
structname=arg[2] or string.gsub(filename(arg[1]), "[-.]", "_")
breaknum = 16	 -- break line after this

fi = assert(io.open(arg[1], "r"))
fo = assert(io.open(outfile, "w"))

data=fi:read("*a")

fo:write(string.format("static const char %s [] = {\n\t", structname))

for i=1,#data do
   fo:write(string.format("0x%.2x, ", string.byte(data, i)))
   if i%breaknum == 0 then fo:write("\n\t") end
end

fo:write("0x00 \n};\n")
