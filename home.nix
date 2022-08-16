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
        inactiveOpacity = "0.8";
        inactiveDim = "0.15";
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
        config = pkgs.substitueAll {
            src = ./polybar-config;
            interface = networkInterface;
        };
        script = ''
            for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
                MONITOR=$m polybar nord &
            done
        '';
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

                keybindings = import ./i3-keybindings.nix config.modifier;
            };
        };
    };
}