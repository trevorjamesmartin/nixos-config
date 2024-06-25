{ pkgs, ... }:

{
    home.packages = with pkgs; [
      (pkgs.writeShellScriptBin "my-neovim" ''
        pushd ~/.config
          if [ -d "nvim/lua/my" ]; then
            cd nvim
            echo "updating neovim config"
            git pull
          else
            echo "installing neovim config"
            git clone https://github.com/trevorjamesmartin/my-neovim.git
            mv my-neovim nvim
          fi
        popd
      '')
    ];

}

