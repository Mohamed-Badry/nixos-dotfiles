{
  config,
  pkgs,
  ...
}:
{
  xdg = {
    desktopEntries = {
      mailspring = {
        name = "Mailspring";
        genericName = "Mail Client";
        exec = "mailspring --password-store=gnome-libsecret %U";
        terminal = false;
        categories = [
          "Network"
          "Email"
        ];
        icon = "mailspring";
      };

      helix = {
        name = "Helix";
        genericName = "Text Editor";
        exec = "${pkgs.wezterm}/bin/wezterm start -- hx %F";
        terminal = false;
        categories = [
          "Utility"
          "TextEditor"
        ];
        icon = "helix";
      };

      zen-pdf = {
        name = "Zen Browser";
        genericName = "Web Browser";
        exec = "zen --new-window %U";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [ "application/pdf" ];
        icon = "zen";
      };

      sioyek = {
        name = "Sioyek";
        genericName = "PDF Viewer";
        comment = "PDF viewer for reading research papers and technical books";
        exec = "sioyek --new-instance %f";
        terminal = false;
        categories = [
          "Development"
          "Viewer"
        ];
        mimeType = [ "application/pdf" ];
        icon = "sioyek-icon-linux";
      };
    };

    mimeApps = {
      enable = true;
      associations.added = {
        "application/pdf" = [
          "sioyek.desktop"
          "zen-pdf.desktop"
        ];
      };
      defaultApplications = {
        "application/pdf" = "sioyek.desktop";
        "inode/directory" = "pcmanfm-qt.desktop";
        "text/plain" = "helix.desktop";
        "text/markdown" = "helix.desktop";
        "application/json" = "helix.desktop";
        "text/x-shellscript" = "helix.desktop";
        "text/x-python" = "helix.desktop";
        "text/x-rust" = "helix.desktop";
        "image/jpeg" = "org.nomacs.ImageLounge.desktop";
        "image/png" = "org.nomacs.ImageLounge.desktop";
        "image/webp" = "org.nomacs.ImageLounge.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "text/html" = "zen.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/mailto" = "Mailspring.desktop";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      projects = "${config.home.homeDirectory}/projects";
    };

    configFile = {
      "Code/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/vscode/settings.json";
      "Code/User/keybindings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/vscode/keybindings.json";
    };
  };
}
