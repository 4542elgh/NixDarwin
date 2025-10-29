{  self, pkgs, config, ...}:

{
    system.primaryUser = "evanliu";

    users.users.evanliu = {
      name = "evanliu";
      home = "/Users/evanliu";
    };

    # Removes old, unused packages and system generations that are no longer needed
    nix.gc = {
      automatic = true;
      interval = [{
        Hour = 4;
        Minute = 30;
        Weekday = 7;
      }];
      options = "--delete-older-than 30d";
    };

    # Deduplicates identical files in the Nix store using hard links (AFTER GC IS DONE)
    # Automatically run the nix store optimiser at a specific time
    nix.optimise = {
      automatic = true;
      interval = [{
        Hour = 4;
        Minute = 15;
        Weekday = 7;
      }];
    };

    # Mostly for broken or incompatibile package pinning (this is modifying global pkgs. instance)
    nixpkgs.overlays = [
    #   (self: super: {
    #     wayland = super.wayland.overrideAttrs (oldAttrs: {
    #       version = "1.23.0";  # use a known working version
    #       src = super.fetchFromGitLab {
    #         domain = "gitlab.freedesktop.org";
    #         owner = "wayland";
    #         repo = "wayland";
    #         rev = "1.23.92";
    #         hash = "";  # leave blank first, let nix figure out
    #       };
    #       meta = oldAttrs.meta // {
    #         broken = false;
    #       };
    #     });
    #   })
    ];


     # MacOSX System configurations
    system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
    system.defaults.dock = {
      autohide = true;
      magnification = true;
      persistent-apps = [
        {
          app = "/Applications/Chromium.app";
        }
        {
          app = "/Applications/Visual Studio Code.app";
        }
      ];
    };
    system.defaults.trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
    };

    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = "x86_64-darwin";

    nixpkgs.config.allowUnfree = true;

    nixpkgs.config.packageOverrides = pkgs: rec {
        # This pin gcc-arm-embedded to version 13 which supports x86_64_darwin for pkgs.qmk (this is a local override)
        gcc-arm-embedded = pkgs.gcc-arm-embedded-13;
    };

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = [ 
        # zsh is installed by default since there is a .nix config for zsh
        # tmux need install since I am just copying conf file, and tmux = enable = true will create its own conf, causing a conflict
        # pkgs.tmux 

        # Make MacOSX alias for spotlight
        pkgs.mkalias
        pkgs.alacritty

        # Micro controller
        pkgs.esphome
        pkgs.qmk

        # # CLI power up
        pkgs.neovim
        pkgs.git
        pkgs.bat
        pkgs.lsd
        pkgs.fzf
        pkgs.yazi
        pkgs.sqlite
        pkgs.ripgrep
        pkgs.silver-searcher
        pkgs.tree
        pkgs.autojump
        pkgs.unzip
        pkgs.wget
        pkgs.yt-dlp

        # Notes
        pkgs.obsidian

        # # Monitoring
        pkgs.htop
        pkgs.gotop
        pkgs.macchina

        # Image and rendering
        pkgs.imagemagick
        pkgs.pandoc

        # Browser
        pkgs.firefox-unwrapped

        # API
        pkgs.bruno

        # Networking
        pkgs.nmap

        # Social
        pkgs.discord
        pkgs.zoom-us

        # Multi media
        pkgs.mpv-unwrapped

        # Transfering
        pkgs.rsync
        pkgs.cyberduck

        # MacOSX
        pkgs.mos # Smooth scrolling
        pkgs.rectangle # Window management
        pkgs.mas # Searching App Store App Id
        pkgs.ice-bar
    ];

    # Whatever is in homebrew (mostly Darwin GUI) are not installable by nixpkgs, homebrew is use as a last resort
    homebrew = {
        enable = true;
        brews = [
            "ncdu" # zig-hook dependencies error
        ];
        casks = [
            # Nix not on latest version
            "iterm2"

            # Need to be in Application folder
            "itsycal" 

            # Build failed
            "mullvad-vpn"
            "sweet-home3d"
            "wireshark-app"

            # Not build for x86 Darwin
            "obs" 
            "via"
            "teamviewer"
            "visual-studio-code"
            "ungoogled-chromium"

            # Does not exist in nixpkgs
            "clipy"
            "alfred"
            "orcaslicer"
            "windows-app"
            "autodesk-fusion"
            "sensiblesidebuttons"
            # "jordanbaird-ice"
            "stats"

            # Need .dmg manual install
            # "omnissa-horizon-client" # This was vmware horizon client
            # "steam" # steam is outdated in cask
            # "downie" # does not show up
            # "aerial" # require companion app only found in .app
            # "karabiner-elements" # some weird bug in homebrew cask package
        ];

# These are App Store apps. App Id obtained via mas.
# You will need to login and have access to these app first.
        masApps = {
            "Bitwarden" = 1352778147; # Only trust from App Store
             "Wireguard" = 1451685025;
            "tailscale" = 1475387142;
            # "Goodnotes" = 1444383602; # Bought with different account
            "Notability" = 360593530;
        };

        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
    };

    fonts.packages = [
        pkgs.nerd-fonts.dejavu-sans-mono
    ];

    # We will set our own zsh CompInit later with a lazy schedule (regen every 24h)
    programs.zsh.enableGlobalCompInit = false;

    # Set Git commit hash for darwin-version.
    system.configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 6;

    # Make alias appear in Alfred. Alfred will look into this folder after some manual configuration.
    system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
        };
    in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
            app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                done
                '';
}
