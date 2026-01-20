{
  name = "nvim-config";
  version = "0.0.1-0";
  mkLuaDeps = env: [
    (env.lua-__.mkPkg env.pkgs)
    env.luaPackages.lua-colors
    env.luaPackages.rapidjson
  ];
  mkPropagatedBuildInputs = env: (
    let
      fromGitHub = repo: ref: rev: env.vimUtils.buildVimPlugin {
        pname = "${env.lib.strings.sanitizeDerivationName repo}";
        version = ref;
        buildInputs = [ env.vimPlugins.plenary-nvim env.git ];
        src = builtins.fetchGit {
          url = "https://github.com/${repo}.git";
          ref = ref;
          rev = rev;
        };
      };
      ofLuaPkg = p: env.neovimUtils.buildNeovimPlugin { luaAttr = p; };
    in with env.vimPlugins; [
      (ofLuaPkg (env.lua-__.mkPkg env.pkgs))
      (ofLuaPkg env.luaPackages.lua-colors)
      (ofLuaPkg env.luaPackages.rapidjson)
      (ofLuaPkg env.luaPackages.fennel)

      aurora
      aylin-vim
      catppuccin-nvim
      dracula-nvim
      kanagawa-nvim
      melange-nvim
      rose-pine
      neomodern-nvim
      bluloco-nvim
      modus-themes-nvim
      onedarkpro-nvim
      oxocarbon-nvim
      (fromGitHub
        "tiagovla/tokyodark.nvim"
        "HEAD"
        "14bc1b3e596878a10647af7c82de7736300f3322")
      (fromGitHub
        "bluz71/vim-moonfly-colors"
        "HEAD"
        "63f20d657c9fd46ecdd75bd45c321f74ef9b11fe")
      (fromGitHub
        "dgox16/oldworld.nvim"
        "HEAD"
        "1b8e1b2052b5591386187206a9afbe9e7fdbb35f")
      (fromGitHub
        "fynnfluegge/monet.nvim"
        "HEAD"
        "af6c8fb9faaae2fa7aa16dd83b1b425c2b372891")
      (fromGitHub
        "maxmx03/fluoromachine.nvim"
        "HEAD"
        "d638ea221b4c6636978f49c1987d10ff2733c23d")

      cmp-nvim-lsp
      cmp-buffer
      cmp-conjure
      cmp-path
      cmp-cmdline
      cmp-vsnip
      nvim-cmp

      nvim-treesitter.withAllGrammars
      snacks-nvim
      nvim-paredit
      conform-nvim
      indent-blankline-nvim

      gitsigns-nvim
      nvim-navic
      rainbow-delimiters-nvim
      venn-nvim
      lualine-lsp-progress
      lualine-nvim
      nvim-autopairs
      orgmode

      (fromGitHub
        "mcauley-penney/tidy.nvim"
        "HEAD"
        "f6c9cfc9ac5a92bb5ba3c354bc2c09a7ffa966f2")
      (fromGitHub
        "shellRaining/hlchunk.nvim"
        "HEAD"
        "5465dd33ade8676d63f6e8493252283060cd72ca")
    ]
  );
}
