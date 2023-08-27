{ inputs, outputs, lib, pkgs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./bash.nix
    ./diceware.nix
    ./less.nix
    ./locale.nix
    ./nix.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  boot = {
    kernel.sysctl = {
      "vm.dirty_ratio" = 6;                         # sync disk when buffer reach 6% of memory
    };
    kernelPackages = pkgs.linuxPackages_latest;     # Latest kernel
  };

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  environment = {
    defaultPackages = []; # Don't install any default programs, force everything
    enableAllTerminfo = true;
    systemPackages = with pkgs; [
      binutils            # standard binutils
      bind                # nslookup and nameserver tools
      coreutils           # gnu core utilities
      curl                # swiss army knife
      du-dust             # rust version of du
      git                 # git
      git-lfs             # git large file support
      htop                # process analysis
      iftop               # network i/o analysis
      inetutils           # internet tools
      iotop               # i/o analysis
      links2              # console web browser
      lsof                # list open files
      mtr                 # traceroute
      ncdu                # disk usage gui
      nano                # editor
      nvd                 # Nix Diffs
      psmisc              # process analysis
      rsync               # Transfer files
      wget                # file fetcher
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      pciutils            # pci statistics
      strace              # debug
    ]);
  };

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  hardware.enableRedistributableFirmware = true;

  host = {
    feature = {
      secrets.enable = true;
    };
    service = {
      ssh = {
        enable = true;
        harden = true;
      };
    };
  };

  networking.domain = "tiredofit.ca";

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  security.sudo.wheelNeedsPassword = false ;

  services.fstrim.enable = lib.mkDefault true;
}
