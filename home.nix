{ config, lib, pkgs, specialArgs, ... }:

let
    zshsettings = import ./zsh.nix pkgs;
    packages = import ./packages.nix;

    # way of determining which machine this is running on
    inherit (specialArgs) withGUI isDesktop networkInterface;

    inherit (lib) mkIf;
    inherit (pkgs.stdenv) isLinux;
in
{
    nixpkgs.config.allowUnfree = true;
    
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
    home.packages = packages pkgs withGUI;

    services.picom = mkIf withGUI {
        enable = true;
        inactiveOpacity = 0.8;
        fadeExclude = [
            "window_type *= 'menu'"
            "name ~= 'Firefox\$'"
            "focused = 1"
        ];
        vSync = true; # workaround with nvidia drivers
    };

    services.polybar = mkIf withGUI {
        enable = true;
        package = pkgs.polybarFull;
        config = pkgs.substituteAll {
            src = ./polybar-config;
            interface = networkInterface;
        };
        script = ''
            for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
                MONITOR=$m polybar nord &
            done
        '';
    };

    xdg.configFile."rofi/colors".source = ./rofi/colors;
    xdg.configFile."rofi/themes".source = ./rofi/themes;

    programs.rofi = {
        enable = true;
        font = "FiraCode NF 12";
        theme = "themes/rofi";
        plugins = [
            pkgs.rofi-emoji
            pkgs.rofi-calc
            pkgs.rofi-power-menu
        ];

        extraConfig = {
            modi = "drun,filebrowser,window";
            show-icons = true;
            sort = true;
            matching = "fuzzy";
        };
    };

    services.lorri.enable = isLinux;
    services.pulseeffects.enable = false;
    services.pulseeffects.preset = "vocal_clarity";
    services.gpg-agent.enable = isLinux;
    services.gpg-agent.enableExtraSocket = withGUI;
    services.gpg-agent.enableSshSupport = isLinux;

    programs.alacritty = (import ./alacritty.nix) withGUI;
    programs.zsh = zshsettings;
    
    programs.direnv.enable = true;
    programs.htop = {
        enable = true;
        settings = {
            left_meters = [ "LeftCPUs2" "Memory" "Swap" ];
            left_right = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
            setshowProgramPath = false;
            treeView = true;
        };
    };
    programs.jq.enable = true;
    programs.ssh = {
        enable = true;
        forwardAgent = true;
    };

    programs.fzf.enable = true;

    programs.git = {
        enable = true;
        lfs.enable = true;
        userName = "Lucy Scarlet";
        userEmail = "yuiyukihira@pm.me";
    };

    xdg.enable = true;

    xsession = mkIf withGUI {
        enable = true; 
        windowManager.i3 = rec {
            enable = true;
            package = pkgs.i3-gaps;
            config = {
                modifier = "Mod4";
                bars = [ ]; # use polybar instead

                gaps = {
                    inner = 12;
                    outer = 5;
                    smartGaps = true;
                    smartBorders = "off";
                };

                startup = [
                    { command = "systemctl --user restart polybar"; always = true; notification = false; }
                ];

                keybindings = import ./i3-keybindings.nix config.modifier;
            };
        };
    };


    home.file = {
        ".config/starship.toml".source = ./starship.toml;

        ".config/nvim".source = pkgs.fetchFromGitHub {
            owner = "AstroNvim";
            repo = "AstroNvim";
            rev = "8782b1a";
            sha256 = "f7c7de1ac9bd8db2b2a462d95cabc5e2d021abb49fd6281086d517ecd20a3be4";
        };
    };
}