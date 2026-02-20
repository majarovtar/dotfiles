{
  description = "maja's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    niteo-claude.url = "github:teamniteo/claude";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, niteo-claude }:
  let
    # Helper function to create pkgsUnstable for any system
    mkPkgsUnstable = system: import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Common modules that can be imported by any system
    commonModules = {
      ai = import ./common/ai.nix;
      direnv = import ./common/direnv.nix;
      files = import ./common/files.nix;
      gitconfig = import ./common/gitconfig.nix;
      zsh = import ./common/zsh.nix;
    };

    homeconfig = { pkgs, lib, pkgsUnstable, commonModules, niteo-claude, ... }: {
      imports = [
        (commonModules.ai { inherit pkgs pkgsUnstable niteo-claude lib; })
        commonModules.direnv
        commonModules.files
        commonModules.gitconfig
        commonModules.zsh
      ];

      # Home Manager configuration
      # https://nix-community.github.io/home-manager/
      home.homeDirectory = lib.mkForce "/Users/maja";
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
      programs.htop.enable = true;
      programs.bat.enable = true;

      # Software I can't live without
      home.packages = with pkgs; [
        pkgsUnstable.devenv
        pkgsUnstable.codex
        pkgs.cachix
        pkgs.python3
        pkgs.heroku
      ];

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      home.file = {
        # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # symlink to the Nix store copy.
        # ".screenrc".source = work/dotfiles/screenrc;

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
      nix.gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 3; Minute = 0; };
        options = "--delete-older-than 30d";
      };

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
    # $ darwin-rebuild build --flake .#MacBook-Air
    darwinConfigurations."MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager  {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.maja = homeconfig;
            home-manager.backupFileExtension = ".backup";
            home-manager.extraSpecialArgs = {
              pkgsUnstable = mkPkgsUnstable "aarch64-darwin";
              inherit commonModules niteo-claude;
            };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Air".pkgs;

    # Support using parts of the config elsewhere
    homeconfig = homeconfig;
  };
}