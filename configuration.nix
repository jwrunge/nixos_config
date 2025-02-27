# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaPersistenced = true;

    prime = {
      offload.enable = true;
      allowExternalGpu = true;

      #integrated
      amdgpuBusId = "PCI:10:00:0";

      # dedicated
      nvidiaBusId = "PCI:1:00:0";
    };
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Networking
  networking = {
    hostName = "nixos";
    nftables.enable = true;
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  nixpkgs.config.allowUnfree = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.nushell;
  users.users.jwr = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"]; # Enable ‘sudo’ for the user.
    home = "/home/jwr";
    shell = pkgs.nushell;
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    mangohud
    protonup
    nftables
    wlr-randr
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/user/.steam/root/compatibilitytools.d";
  };

  programs.firefox.enable = true;
  programs.hyprland.enable = true;

  stylix = {
    enable = true;
    image = ./wallpaper2.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    homeManagerIntegration.followSystem = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; #disable password login
    };
    openFirewall = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.blueman.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      apps = [
        {
          name = "Desktop";
          # prep-cmd = [
          #   {
          #     do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.2560x1440@144";
          #     undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.3440x1440@144";
          #   }
          # ];
          # exclude-global-prep-cmd = "false";
          # detached = ["setsid ${pkgs.steam}/bin/steam"];
          cmd = "${pkgs.steam}/bin/steam steam://open/bigpicture";
          auto-detach = "true";
        }
        {
          name = "Steam";
          # prep-cmd = [
          #   {
          #     do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.2560x1440@144";
          #     undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.3440x1440@144";
          #   }
          # ];
          # exclude-global-prep-cmd = "false";
          # detached = ["setsid ${pkgs.firefox}/bin/firefox"];
          cmd = "setsid ${pkgs.firefox}/bin/firefox";
          auto-detach = "true";
        }
      ];
    };
  };

  programs.gamemode.enable = true;

  # Do NOT change this value
  system.stateVersion = "24.11"; # Did you read the comment?
}
