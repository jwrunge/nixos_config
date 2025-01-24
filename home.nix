{ config, pkgs, lib, ... }:
{
  home.username = "jwr";
  home.homeDirectory = "/home/jwr";

  home.packages = with pkgs; [
    neofetch
    rancher
    
    # archives
    zip
    xz
    unzip

    # utils
    ripgrep	# recursive regex search
    jq		# JSON processor
    fzf		# fuzzy finder
    nix-output-monitor # `nom` - replace `nix` with more logging
    htop	# better btop
    iotop	# io monitoring
    iftop	# net monitoring
    sysstat
    ethtool
    pciutils	# lspci
    usbutils	# lsusb

    # networking
    mtr 	# net diagnostics
    nmap	# network discovery and security

    # tools
    helix-gpt
    ranger
    lazygit
    git-credential-manager
    chromium
  ];

  # hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 2;
        resize_on_border = true;
        hover_icon_on_border = true;
        "col.active_border" = lib.mkForce "rgba(33ccffee) rgba(00ff99ee) 45deg";
      };
      decoration = {
        rounding = 5;
      };
      bind = [
          "$mod, T, exec, ghostty"
          "$mod, B, exec, chromium"
          ", Print, exec, grimblast copy area"
        ]        
        ++ (
          builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
        9)
      );
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        spacing = 5;
        modules-left = ["hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = ["cpu" "memory" "network" "bluetooth" "pulseaudio" "clock#date" "clock#time"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          active-only = true;
          warp-on-scroll = false;
        };

        clock = {
          format = "{:%I:%M %p - %a, %d $b $Y}";
        };
        
        cpu = {
          format = "{icon} {usage}%";
          interval = 2;

          states = {
            critical = 90;
          };
        };
        
        memory = {
          format = "{icon} {percentage}%";
          interval = 2;

          states = {
            critical = 80;
          };
        };

        network = {
          format-ethernet = "{icon} {bandwidthDownBits}";
          format-disconnected = "{icon}";
          interval = 5;
          tooltip = false;
        };

        pulseaudio = {
          scroll-step = 5;
          max-volume = 150;
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          nospacing = 1;
          on-click = "pavucontrol";
          tooltip = false;
        };
      };
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      background = "black";
      "background-opacity" = 0.8;
    };
  };
  
  # git conifg
  programs.git = {
    enable = true;
    userName = "jwrunge";
    userEmail = "jwrunge@gmail.com";
    extraConfig.credential = {
      helper = "manager";
      "https://github.com".username = "jwrunge";
      credentialStore = "cache";
    };
  };

  # helix config
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
  
  # nushell
  programs.nushell = {
    enable = true;

    extraConfig = ''
      $env.config = {
        show_banner: false,
        completions: {
          case_sensitive: false	# case-sensitive completions
          quick: true		# false prevents auto-selecting completions
          partial: true		# false prevents partial filling of prompt
          algorithm: fuzzy	# prefix or fuzzy
          
          external: {
            enable: true 	#false prevents nushell from looking into $env.PATH
            max_results: 100	
          }
        }
      }

      $env.PATH = ($env.PATH | split row (char esep) | prepend /home/jwr/.apps | append /usr/bin/env)
    '';
  };
  
  #carapace.enable = true;
  #carapace.enableNushellIntegration = true;


  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
