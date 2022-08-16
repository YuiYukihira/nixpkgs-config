pkgs: withGui: with pkgs; [
    # these files are meant to be installed in all scenarios
    bat
    binutils
    bottom
    cargo

    dbus
    direnv
    fd
    git
    gh
    gnupg
    gnumake
    htop

    # For terminal
    nerdfonts
    starship

    # For nvim
    neovim
    ripgrep
    lazygit
    ncdu
    python310
    nodejs
    xclip

] ++ pkgs.lib.optionals WithGUI [
    brightnessctl
    enlightment.terminology
    firefox
    pavucontrol

    neovide
]