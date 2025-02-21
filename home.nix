{ pkgs
, lib
, ...
}: {
  home.username = "jwr";
  home.homeDirectory = "/home/jwr";

  fonts = {
    fontconfig.enable = true;
  };

  home.packages = with pkgs; [
    # Fonts
    # nerd-fonts.0xproto
    nerd-fonts._3270
    nerd-fonts.agave
    nerd-fonts.anonymice
    nerd-fonts.arimo
    nerd-fonts.aurulent-sans-mono
    nerd-fonts.bigblue-terminal
    nerd-fonts.bitstream-vera-sans-mono
    nerd-fonts.blex-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.code-new-roman
    nerd-fonts.comic-shanns-mono
    nerd-fonts.commit-mono
    nerd-fonts.cousine
    nerd-fonts.d2coding
    nerd-fonts.daddy-time-mono
    nerd-fonts.departure-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.envy-code-r
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
    nerd-fonts.hack
    nerd-fonts.hasklug
    nerd-fonts.heavy-data
    nerd-fonts.hurmit
    nerd-fonts.im-writing
    nerd-fonts.inconsolata
    nerd-fonts.inconsolata-go
    nerd-fonts.inconsolata-lgc
    nerd-fonts.intone-mono
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka-term-slab
    nerd-fonts.jetbrains-mono
    nerd-fonts.lekton
    nerd-fonts.liberation
    nerd-fonts.lilex
    nerd-fonts.martian-mono
    nerd-fonts.meslo-lg
    nerd-fonts.monaspace
    nerd-fonts.monofur
    nerd-fonts.monoid
    nerd-fonts.mononoki
    nerd-fonts.mplus
    nerd-fonts.noto
    nerd-fonts.open-dyslexic
    nerd-fonts.overpass
    nerd-fonts.profont
    nerd-fonts.proggy-clean-tt
    nerd-fonts.recursive-mono
    nerd-fonts.roboto-mono
    nerd-fonts.shure-tech-mono
    nerd-fonts.sauce-code-pro
    nerd-fonts.space-mono
    nerd-fonts.symbols-only
    nerd-fonts.terminess-ttf
    nerd-fonts.tinos
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    nerd-fonts.ubuntu-sans
    nerd-fonts.victor-mono
    nerd-fonts.zed-mono

    neofetch
    rancher
    _1password-gui

    # archives
    zip
    xz
    unzip

    # utils
    ripgrep # recursive regex search
    jq # JSON processor
    fzf # fuzzy finder
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
    alejandra
    nixd

    godot_4
    logiops

    # js
    eslint
    nodejs_23
    typescript
    typescript-language-server
    vscode-langservers-extracted
    emmet-ls
    nodePackages.prettier
  ];

  programs.wofi.enable = true;

  # hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
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
        "w[tv1], gapsout:0, gapsin:0, bordersize:0, decorate:false"
      ];
      bind =
        [
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
            (
              i:
              let
                ws = i + 1;
              in
              [
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
        modules-right = [ "cpu" "custom/igpu-usage" "custom/gpu-usage" "memory" "disk" "network" "pulseaudio" "clock" ];

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

        "custom/igpu-usage" = {
          exec = "cat /sys/class/hwmon/hwmon4/device/gpu_busy_percent";
          format = "{icon} {}%";
          return-type = "";
          interval = 1;
          format-icons = [ "󰔶" ];
        };

        "custom/gpu-usage" = {
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
          format = "{icon} {}%";
          interval = 2;
          format-icons = [ "󱎓" ];
        };

        disk = {
          interval = 30;
          format = "  {free} | {percentage_free}%";
          unit = "GB";
        };

        memory = {
          format = "{icon} {percentage}%";
          interval = 2;
          format-icons = [ "" ];

          states = {
            critical = 80;
          };
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
      command = "zellij attach MAIN -c";
      "window-decoration" = false;
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
        gpt = {
          command = "${pkgs.helix-gpt}/bin/helix-gpt";
        };

        ts = {
          command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
          args = [ "--stdio" ];
          tsserver = {
            path = "./node_modules/typescript/lib";
            fallbackPath = "${pkgs.typescript}/lib/node_modules/typescript/lib";
          };
        };

        eslint = {
          command = "${pkgs.eslint}/bin/eslint";
          args = [ "--stdio" ];
          config = {
            codeActionsOnSave = {
              mode = "all";
              source.fixAll.eslint = true;
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
              disableRuleComment = {
                enable = true;
                location = "separateLine";
              };
              showDocumentation = { enable = true; };
            };
          };
          workingDirectory = { mode = "location"; };
        };

        nixd = {
          command = "nixd";
          filetypes = [ "nix" ];
          config.nixd = {
            formatting.command = [ "${pkgs.alejandra}/bin/alejandra" ];
            nix.flake.autoEvalInputs = true;
          };
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          file-types = [ "nix" ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
          formatter = { command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"; };
          language-servers = [ "nixd" ];
        }
        {
          name = "typescript";
          language-servers = [ "ts" ];
          file-types = [ "ts" "tsx" "mts" "cts" ];
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--stdin-filepath" "--parser" "typescript" ];
          };
          auto-format = true;
        }
      ];
    };
  };

  programs.zellij.enable = true;

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
            # max_results: 100
          }
        }
      }

      $env.PATH = ($env.PATH | split row (char esep) | prepend /home/jwr/.apps | append /usr/bin/env)
    '';
  };

  home.stateVersion = "24.11";

  programs.home-manager = {
    enable = true;
  };
}
