_: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = ["git" "python" "sudo" "direnv"];
    };
    sessionVariables = {
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      EDITOR = "~/.editor";

      # Enable a few neat OMZ features
      HYPHEN_INSENSITIVE = "true";
      COMPLETION_WAITING_DOTS = "true";

      # Disable generation of .pyc files
      # https://docs.python-guide.org/writing/gotchas/#disabling-bytecode-pyc-files
      PYTHONDONTWRITEBYTECODE = "0";
    };
    shellAliases = {
      nixre = "sudo darwin-rebuild switch --flake ~/work/dotfiles#Majas-MacBook-Air";
      nixup = "cd ~/work/dotfiles && nix flake update && nixre";
      nixgc = "nix-collect-garbage";
      nixcfg = "code ~/work/dotfiles";
      c = "code .";
      ga = "git add -p";
    };
    history = {
      append = true;
      share = true;
    };
    initContent = ''
      # Source secrets if available
      [[ -f ~/work/dotfiles/secrets.env ]] && source ~/work/dotfiles/secrets.env

      function edithosts {
          export EDITOR="code --wait"
          sudo -e /etc/hosts
          echo "* Successfully edited /etc/hosts"
          sudo dscacheutil -flushcache && echo "* Flushed local DNS cache"
      }
    '';
  };
}
