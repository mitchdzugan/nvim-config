package = "nvim-config"
version = "0.0.1-0"
source = {
  url = "https://github.com/mitchdzugan/__.lua/archive/refs/heads/main.zip",
  dir = "__.lua-main"
}
description = {
   summary = "fennel utils",
   detailed = "",
   homepage = "https://github.com/mitchdzugan/__.lua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      __ = "dist/__.lua"
   }
}
