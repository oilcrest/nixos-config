{lib, ...}:

with lib;
{
  imports = [
    ./bluetooth.nix
    ./cpu
    ./gpu
    ./monitors.nix
    ./printing.nix
    ./raid.nix
    ./sound.nix
    ./touchpad.nix
    ./webcam.nix
    ./wireless.nix
    ./yubikey.nix
  ];
}