# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Networking
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.nushell;
  users.users.jwr = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
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
  ];

  programs.firefox.enable = true;
  programs.hyprland.enable = true;

  stylix = {
    enable = true;
    image = ./wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    homeManagerIntegration.followSystem = true;
    
  };

 # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      AllowUsers = [ "jwr" ];
      UseDns = true;
      PermitRootLogin = "no"; #disable root login
      PasswordAuthentication = true; #disable password login
    };
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # Do NOT change this value
  system.stateVersion = "24.11"; # Did you read the comment?
}

