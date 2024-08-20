{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    neovim 
  ];
  
  # Add config
  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n"; # Allows lua code
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n"; # Allows lua files
  in
  {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      rnix-lsp

      xclip
      wl-clipboard
    ];

    plugins = with pkgs.vimPlugins; [

      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./nvim/plugin/lsp.lua;
      }

      {
        plugin = comment-nvim;
        config = toLua "require(\"Comment\").setup()";
      }
    ]
  }
}
