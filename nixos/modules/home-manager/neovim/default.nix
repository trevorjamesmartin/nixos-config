{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.neovim;
in {
  options.yoshizl.neovim.enable = mkEnableOption "enable neovim";

  config = mkIf cfg.enable {
    
    home.sessionVariables.EDITOR = "nvim";

    home.packages = [
      pkgs.neovim

      (pkgs.writeShellScriptBin "my-neovim" ''
        pushd ~/.config
          if [ -d "nvim/lua/my" ]; then
            cd nvim
            echo "updating neovim config"
            git pull
          else
            echo "cloning neovim config"
            git clone https://github.com/trevorjamesmartin/my-neovim.git
            if [ -d "nvim" ]; then
              echo "renaming previous neovim configuration"
              mv nvim nvim-previous
            fi
            echo "installing neovim config"
            mv my-neovim nvim
          fi
        popd
      '')

      (pkgs.writeShellScriptBin "neovim-js-debug" ''
        pushd ~/.local/share/nvim/lazy
        if [ -d "vscode-js-debug" ]; then
          cd vscode-js-debug
          rm -rf out
          git pull
        else
          git clone https://github.com/microsoft/vscode-js-debug
          cd vscode-js-debug
        fi
        npm install --legacy-peer-deps
        npx gulp vsDebugServerBundle
        mv dist out
        popd
      '')
    ];
  
  };

}
