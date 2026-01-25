{
  inputs = {
    # lua-__.url = "path:/VOID/proj/__.lua";
    # lua-__.url = "path:/home/dz/Projects/__.lua";
    lua-__.url = "github:mitchdzugan/__.lua";
    # mitch-utils.url = "path:/VOID/proj/mitch-utils.nix";
    # mitch-utils.url = "path:/home/dz/Projects/mitch-utils.nix";
    mitch-utils.url = "github:mitchdzugan/mitch-utils.nix";
  };
  outputs = inputs@{ mitch-utils, ... }: (mitch-utils.mkZnFnl inputs ./.);
}
