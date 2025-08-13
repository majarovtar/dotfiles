{
  description = "maja's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager }:
  let
    secrets = import /Users/maja/.dotfiles/secrets.nix;

    homeconfig = { pkgs, lib, ... }: {
      # Home Manager configuration
      # https://nix-community.github.io/home-manager/
      home.homeDirectory = lib.mkForce "/Users/maja";
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
      programs.htop.enable = true;
      programs.bat.enable = true;

      # Software I can't live without
      home.packages = with pkgs; [
        (import nixpkgs-unstable { system = "aarch64-darwin"; }).devenv
        (import nixpkgs-unstable { system = "aarch64-darwin"; config.allowUnfree = true; }).claude-code
        (import nixpkgs-unstable { system = "aarch64-darwin"; config.allowUnfree = true; }).codex
        pkgs.cachix
        pkgs.python3
        pkgs.heroku
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.git = {
        enable = true;
        diff-so-fancy.enable = true;
        userName = "Maja Rovtar";
        userEmail = secrets.email;
        extraConfig = {
          core = {
            editor = "nano";
          };
          diff = {
            tool = "diffmerge";
          };
          github = {
            user = "majarovtar";
          };
        };
        ignores = [
          # Packages: it's better to unpack these files and commit the raw source
          # git has its own built in compression methods
          "*.7z"
          "*.dmg"
          "*.gz"
          "*.iso"
          "*.jar"
          "*.rar"
          "*.tar"
          "*.zip"

          # OS generated files
          ".DS_Store"
          ".DS_Store?"
          "ehthumbs.db"
          "Icon?"
          "Thumbs.db"

          # Sublime
          "sublime/*.cache"
          "sublime/oscrypto-ca-bundle.crt"
          "sublime/Package Control.last-run"
          "sublime/Package Control.merged-ca-bundle"
          "sublime/Package Control.user-ca-bundle"

          # VS Code
          "vscode/History/"
          "vscode/globalStorage/"
          "vscode/workspaceStorage/"

          # Secrets
          "ssh_config_private"
        ];
      };

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
          nixre = "sudo darwin-rebuild switch --flake ~/.dotfiles#Majas-MacBook-Air --impure";
          nixcfg = "code ~/.dotfiles";    
          c = "code .";
          ga = "git add -p";
        };
        history = {
          append = true;
          share = true;
        };
        # Use VSCode as the default editor on the Mac
        home.file.".editor" = {
          executable = true;
          text = ''
            #!/bin/bash
            # https://github.com/microsoft/vscode/issues/68579#issuecomment-463039009
            code --wait "$@"
            open -a Terminal
          '';
        };
        initContent = ''
          function edithosts {
              export EDITOR="code --wait"
              sudo -e /etc/hosts
              echo "* Successfully edited /etc/hosts"
              sudo dscacheutil -flushcache && echo "* Flushed local DNS cache"
          }        
        '';
      };

      # Don't show the "Last login" message for every new terminal.
      home.file.".hushlogin" = {
        text = "";
      };

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      home.file = {
        # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # symlink to the Nix store copy.
        # ".screenrc".source = .dotfiles/screenrc;

        # You can also set the file content immediately.
        ".editor" = {
          executable = true;
          text = ''
            #!/bin/bash
            # https://github.com/microsoft/vscode/issues/68579#issuecomment-463039009
            code --wait "$@"
            open -a Terminal
          '';
        };
      };
      
    };
    configuration = { pkgs, ... }: {
      # Use nix from pinned nixpkgs
      # services.nix-daemon.enable = true;
      nix.settings.trusted-users = [ "@admin maja" ];
      nix.package = pkgs.nix;

      # Using flakes instead of channels
      nix.settings.nix-path = ["nixpkgs=flake:nixpkgs"];

      # Allow licensed binaries
      nixpkgs.config.allowUnfree = true;

      # Save disk space
      nix.optimise.automatic = true;

      # Longer log output on errors
      nix.settings.log-lines = 25;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Configure Cachix
      nix.settings.substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
        "https://niteo.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "niteo.cachix.org-1:GUFNjJDCE199FDtgkG3ECLrAInFZEDJW2jq2BUQBFYY="
      ];

      # set netrc for automatic login processes (e.g. for cachix)
      nix.settings.netrc-file = "/Users/maja/.config/nix/netrc";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      #
      # My personal settings
      #
      system.primaryUser = "maja";
      system.defaults.screencapture.location = "~/Downloads";
      # Enable touch ID authentication for sudo.
      security.pam.services.sudo_local.touchIdAuth = true;
      #
      # End of my personal settings
      #
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Majas-MacBook-Air
    darwinConfigurations."Majas-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager  {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.maja = homeconfig;
            home-manager.backupFileExtension = ".backup";
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Majas-MacBook-Air".pkgs;

    # Support using parts of the config elsewhere
    homeconfig = homeconfig;
  };
}