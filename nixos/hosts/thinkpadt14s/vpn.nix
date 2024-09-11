{ config, lib, pkgs, ... }: {
  services.openvpn.servers = {
    current = {
      autoStart = false;
      updateResolvConf = true;
      config = "config /home/tm/ovpn/current";
    };
  };
  environment.systemPackages = with pkgs; [
    # vpn tools
    wireguard-tools
    openvpn
  ];

}
