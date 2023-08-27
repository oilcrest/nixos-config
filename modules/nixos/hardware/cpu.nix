{config, lib, pkgs, ...}:
with lib;
{
  imports = [
    ./cpu/amd.nix
    ./cpu/intel.nix
  ];

  options = {
    host.hardware = {
      cpu = mkOption {
        type = types.enum ["pi" "amd" "intel" "vm-amd" "vm-intel" null];
        default = null;
        description = "Type of CPU: intel, vm-intel, amd, vm-amd";
      };
    };
  };
}