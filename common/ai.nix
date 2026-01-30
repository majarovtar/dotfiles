{
  pkgsUnstable,
  niteo-claude,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = pkgsUnstable.claude-code;

    # Get team MCPs from teamniteo/claude
    mcpServers = niteo-claude.lib.mcpServers pkgs // {};

    settings = {
      # Get team Plugins from teamniteo/claude
      enabledPlugins = niteo-claude.lib.enabledPlugins // {};

      # Get team Permissions from teamniteo/claude
      permissions.allow = niteo-claude.lib.permissions.allow ++ [
        # Auto-allow read-only commands in common directories
        "Read(~/work/*)"
        "Read(~/tmp/*)"
        "Bash(cat ~/work/*)"
        "Bash(cat /tmp/*)"
        "Bash(head ~/work/*)"
        "Bash(head /tmp/*)"
        "Bash(ls ~/work/*)"
        "Bash(ls /tmp/*)"
        "Bash(tail ~/work/*)"
        "Bash(tail /tmp/*)"
      ];
    };

    # Personal CLAUDE.md content
    memory.text = ''
      # About the User

      Maja Rovtar (majarovtar) - Junior Developer at Niteo. Based in Ljubljana, Slovenia.

      - Passionate about code quality, testing, and continuous delivery.
      - Enjoys learning new technologies and improving development skills.

      **GitHub:** github.com/majarovtar - use the GitHub MCP to access private repos when needed.
      **Workstation:** github.com/majarovtar/dotfiles - usually invokes Claude from the MacBook defined in these dotfiles.
    '';
  };
}
