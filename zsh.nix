pkgs: {
    enable = true;

    initExtra = ''
        eval "$(starship init zsh)"
    '';
}