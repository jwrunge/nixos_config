{ pkgs, lib, ... }:
{
  home.username = "jwr";
  home.homeDirectory = "/home/jwr";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    #fonts
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    proggyfonts

    neofetch
    rancher

    # archives
    zip
    xz
    unzip

    # utils
    ripgrep # recursive regex search
    jq # JSON processor
    fzf # fuzzy finder
    nix-output-monitor # `nom` - replace `nix` with more logging
    htop # better btop
    iotop # io monitoring
    iftop # net monitoring
    sysstat
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # networking
    mtr # net diagnostics
    nmap # network discovery and security

    # tools
    helix-gpt
    ranger
    lazygit
    git-credential-manager
    chromium

    # helix tools
    nixpkgs-fmt
    nil
    nixd

    godot_4
    logiops

    # js
    nodejs_23
    typescript
    typescript-language-server
    vscode-langservers-extracted
    emmet-ls
    prettierd
  ];

  programs.wofi.enable = true;

  # hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      general = {
        gaps_in = 4;
        gaps_out = 4;
        border_size = 2;
        resize_on_border = true;
        hover_icon_on_border = true;
        "col.active_border" = lib.mkForce "rgba(da42f5ee) rgba(4299f5ee) 45deg";
      };
      decoration = {
        rounding = 5;
      };
      workspace = [
        "w[1], gapsout:0, gapsin:0, bordersize:0, decorate:false"
      ];
      bind = [
        "$mod, T, exec, ghostty"
        "$mod, B, exec, chromium"
        "$mod, SPACE, exec, wofi --show=drun"
        "$mod, Q, killactive"
        "$mod, TAB, cyclenext"
        "$mod, DELETE, exec, hyprctl dispatch exit"
        ", Print, exec, grimblast copy area"
      ]
      ++ (
        builtins.concatLists (builtins.genList
          (i:
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

    style = ''
      * {
        font-family: "Arimo Nerd Font", "Font Awesome 6 Free";
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        spacing = 5;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "cpu" "memory" "network" "pulseaudio" "clock" ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          active-only = false;
          warp-on-scroll = false;
        };

        clock = {
          format = "{:%m/%d/%y %I:%M}";
        };

        cpu = {
          format = "{icon} {usage}%";
          interval = 2;
          format-icons = [ "" ];

          states = {
            critical = 90;
          };
        };

        "custom/gpu-usage" = {
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
          format = "{icon} {}%";
          interval = 2;
          format-icons = [ "󱎓" ];
        };

        memory = {
          format = "{icon} {percentage}%";
          interval = 2;
          format-icons = [ "" ];

          states = {
            critical = 80;
          };
        };

        disk =
          {
            format = "{icon} {used}/{free}";
            format-icons = [ "" ];
          };

        network = {
          format-ethernet = "{icon} {bandwidthDownBits}";
          interval = 5;
          tooltip = false;
          format-icons = [ "" ];
        };

        pulseaudio = {
          scroll-step = 5;
          max-volume = 150;
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          nospacing = 1;
          on-click = "pavucontrol";
          tooltip = false;
          format-icons = [ "" "󰂰" ];
        };
      };
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      background = "black";
      "background-opacity" = 0.7;
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
    settings = {
      theme = lib.mkForce "withTransparency";
      editor = {
        line-number = "relative";
        lsp.display-inlay-hints = true;
        bufferline = "multiple";
        cursor-shape.normal = "bar";
        cursor-shape.insert = "bar";
        cursor-shape.select = "bar";
      };
    };
    themes = {
      withTransparency = {
        inherits = "stylix";
        "ui.background" = "{ bg = \"#00000000\" }";
      };
    };
    languages = {
      language-server = {
        typescript-language-server = with pkgs.nodePackages; {
          command = "${typescript-language-server}/bin/typescript-language-server";
          args = [ "--stdio" "--tsserver-path=${typescript}/lib/node_modules/typescript/lib" ];
        };

        eslint = {
          command = "vscode-eslint-language-server";
          args = [ "--stdio" ];
          config = {
            codeActionsOnSave = {
              mode = "all";
              "source.fixAll.eslint" = true;
            };
            format = {
              enable = true;
            };
            nodePath = "";
            quiet = false;
            rulesCustomizations = [ ];
            run = "onType";
            validate = "on";
            experimental = { };
            problems = {
              shortenToSingleLine = false;
            };
            codeAction = {
              disableRuleComment = { enable = true; location = "separateLine"; };
              showDocumentation = { enable = false; };
            };
          };
        };

        nil = {
          command = "nil";
          config.nil = {
            formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
            nix.flake.autoEvalInputs = true;
          };
        };
      };


      language = [{
        name = "nix";
        auto-format = true;
        file-types = [ "nix" ];
        indent = { tab-width = 2; unit = " "; };
        formatter = { command = "nixpkgs-fmt"; };
        language-servers = [ "nil" ];
      }
        {
          name = "typescript";
          language-servers = [ "typescript-language-server" "eslint" "emmet-ls" ];
          formatter = {
            command = "prettierd";
            args = [ "." "--write" ];
          };
          auto-format = true;
        }];
    };
  };

  programs.zellij.enable = true;

  # nushell
  programs.nushell = {
    enable = true;

    configFile.text = ''
      # zellij
      def start_zellij [] {
        if 'ZELLIJ' not-in ($env | columns) {
          if 'ZELLIJ_AUTO_ATTACH' in ($env | columns) and $env.ZELLIJ_AUTO_ATTACH == 'true' {
            zellij attach -c
          } else {
            zellij
          }

          if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
            exit
          }
        }
      }

      start_zellij
    '';

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
            # max_results: 100	
          }
        }
      }

      $env.PATH = ($env.PATH | split row (char esep) | prepend /home/jwr/.apps | append /usr/bin/env)
    '';
  };

  #carapace.enable = true;
  #carapace.enableNushellIntegration = true;


  home.stateVersion = "24.11";

  programs.home-manager = {
    enable = true;
  };
}
