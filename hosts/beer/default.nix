{ pkgs, inputs, ...}: {
let
 resolutionfix = pkgs.writeShellScriptBin "resolution_fix" ''
    sudo cvt 2560 1080 60
    sudo xrandr --newmode "2560x1080_60.00"  230.00  2560 2720 2992 3424 1080 1083 1093 1120 -hsync +vsync
    sudo xrandr --addmode HDMI-1 2560x1080_60.00
  '';
in
{
imports = [
    ./hardware-configuration.nix
    ../common/global
  ];

  boot = {
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
    kernelParams = [ "video=2560x1080@60" ];
  };

  environment.systemPackages = with pkgs; [
    arandr
    libraspberrypi
    resolutionfix
    xorg.libxcvt
    xterm
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      btrfs.enable = false;
    };
    network = {
      hostname = "beer";
    };
    role = "kiosk";
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };

  networking = {
    hostName = "beer";
  };

  services.xserver = {
    videoDrivers = [ "fbdev" ];
  };
}
