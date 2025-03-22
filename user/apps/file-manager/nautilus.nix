{ config, pkgs, ... }:

{
  # Add Nautilus to user packages
  home.packages = with pkgs; [
    nautilus  # Nautilus file manager
    adwaita-icon-theme  # Default GNOME icon theme for consistency
  ];

  # Configure GTK settings for dark theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";  # Use GNOME's default dark theme
      package = pkgs.gnome-themes-extra;  # Provides Adwaita-dark
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;  # Default GNOME icons
    };
  };

  # Configure Nautilus-specific settings via dconf
  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";  # Default to icon view
      search-filter-time-type = "last_modified";  # Filter search by modification time
    };
    "org/gnome/nautilus/window-state" = {
      maximized = false;  # Start non-maximized
      initial-size = [ 800 600 ];  # Default window size
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";  # Enforce dark theme for GNOME apps
    };
  };

  # Optional: Ensure Nautilus respects the dark theme environment-wide
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";  # Force GTK apps (including Nautilus) to use dark theme
  };
}


