{ inputs, pkgs, ... }:

{
    home.file."neovim-js-debug.sh".source =
      let
        script = pkgs.writeShellScriptBin "neovim-js-debug.sh" ''
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
 
        '';
      in
      "${script}/bin/neovim-js-debug.sh";
}
