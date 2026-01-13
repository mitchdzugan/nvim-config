{
  inputs = {
    lua-__.url = "path:/VOID/proj/__.lua";
    mitch-utils.url = "path:/VOID/proj/mitch-utils.nix";
    # mitch-utils.url = "github:mitchdzugan/mitch-utils.nix";
  };
  outputs = inputs@{ mitch-utils, ... }: (mitch-utils.mkZnFnl inputs ./.);
}
