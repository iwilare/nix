{ pkgs, inputs, ... }: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.tabClipWidth" = 83;
        "layout.css.backdrop-filter.enabled" = true;
        "layout.css.color-mix.enabled" = true;
        "svg.context-properties.content.enabled" = true;
        "network.protocol-handler.external.mailto" = false;
        "browser.tabs.unloadOnLowMemory" = true;
        "security.insecure_connection_text.enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
      };
      userChrome = ''@import "material-firefox-updated/userChrome.css";'';
      userContent = ''@import "material-firefox-updated/userContent.css";'' ;
      # builtins.readFile ./assets/userChrome.css;
      # extensions.packages = [
      #   nur.repos.rycee.firefox-addons.ublock-origin
      #   nur.repos.rycee.firefox-addons.youtube-nonstop
      # ];
    };
  };
  home.file.material-fox = {
    source = inputs.material-fox-updated;
    target = ".mozilla/firefox/default/chrome/material-firefox-updated";
  };
}
