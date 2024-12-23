{
  description = "My personal Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [ 
        pkgs.neovim
        pkgs.git
        pkgs.gnumake
        pkgs.mkalias
        pkgs.htop
        pkgs.nodejs_22
        pkgs.lunarvim
        pkgs.rustup
        pkgs.cairo
        pkgs.gtk4
        pkgs.poppler
        pkgs.glib
        pkgs.viu
        pkgs.poppler_utils
        pkgs.go
        pkgs.qemu
        pkgs.k9s
        pkgs.lazygit
        pkgs.openvpn
        pkgs.netcat-gnu
        pkgs.fish
        pkgs.fastfetch
    ];

    fonts.packages = [
        pkgs.jetbrains-mono
    ];

    homebrew = {
      enable = true;
      casks = [
        "wezterm"
        "the-unarchiver"
        "spotify"
        "orbstack"
        "stats"
        "element"
        "orion"
        "discord"
        "secretive"
        "whatsapp"
        "vmware-fusion"
        "utm"
        "signal"
        "miniconda"
        "visual-studio-code"
        "aldente"
        "intellij-idea"
        "firefox"
      ];
      brews= [
        "pkg-config"
        "poppler"
        # "fish"
        # All package you want to install with brew
      ];

      masApps = {
        # All package you want to install from the AppStore
        # "Yoink" = <insert id>
      };
      onActivation.cleanup = "zap";
      onActivation.autoUpdate = true;
      onActivation.upgrade = true;
    };

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
        # rm -rf /Applications/Nix\ Apps
        # mkdir -p /Applications/Nix\ Apps
        # find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        # while read src; do
        #     app_name=$(basename "$src")
        #     echo "copying $src" >&2
        #     ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        # done
    '';


      system.defaults = {
        dock.persistent-apps = [
          "/Applications/Orion.app"
          "/Applications/WezTerm.app"
          "/Applications/Discord.app"
          "/Applications/Spotify.app"
          "/Applications/OrbStack.app"
          "/Applications/Microsoft Word.app"
          "/System/Applications/Messages.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Launchpad.app"
        ];
        trackpad.Clicking = true;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      # programs.zsh.enable = true;  # default shell on catalina
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew 
        {
          nix-homebrew = { 
              enable = true;
              enableRosetta = true;
              user = "i5-650";
              autoMigrate = true;
           };
        } 
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}
