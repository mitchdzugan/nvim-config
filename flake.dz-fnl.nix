{
  name = "nvim-config";
  version = "0.0.1-0";
  mkLuaDeps = env: [
    (env.lua-__.mkPkg env.pkgs)
    env.luaPackages.lua-colors
    env.luaPackages.rapidjson
  ];
}
