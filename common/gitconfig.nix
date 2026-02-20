_: {
  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Maja Rovtar";
        email = "70475196+majarovtar@users.noreply.github.com";
      };
      };
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
}
