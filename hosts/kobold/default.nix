{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      encryption.enable = true;             # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;           # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      gpu = "integrated-amd";
      raid.enable = ;                  # This line can be removed if not needed as it is already default set by the role template
      sound = {
        server = "pulseaudio";
      };
    };
    network = {
      hostname = "kobold";
    };
    role = "laptop";
    user = {
      root.enable = true;
    };
  };
}
