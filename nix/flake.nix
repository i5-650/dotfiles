{
  description = "My personal Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    username = "i5-650";  # Nom d'utilisateur cohérent

    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [

        (pkgs.writeScriptBin "nix-switch" ''
          #!${pkgs.runtimeShell}
          exec sudo darwin-rebuild switch --flake ~/.config/nix#i5-650
        '')

        # Programming
        pkgs.rustup
        pkgs.go
        pkgs.php
        pkgs.llvm
        pkgs.gnumake
        pkgs.cmake
        pkgs.gcc
        pkgs.clang-tools
        pkgs.gdb
        pkgs.python3
        pkgs.python312Packages.pip
        pkgs.pipx

        # DevOps
        pkgs.k9s
        pkgs.kubecm
        pkgs.ansible
        pkgs.kubernetes-helm

        # Shell
        pkgs.starship
        pkgs.neovim
        pkgs.tmux
        pkgs.zellij

        # Virtualisation
        pkgs.qemu
        pkgs.lima

        # Security
        pkgs.nmap
        pkgs.hashcat
        pkgs.trivy

        # VSC
        pkgs.git
        pkgs.lazygit

        # Web
        pkgs.atac
        pkgs.curl
        pkgs.nodejs_22

        # Network
        pkgs.openvpn
        #pkgs.traceroute #TODO
        pkgs.tcpdump

        # Utils
        pkgs.htop
        pkgs.viu
        pkgs.fd
        pkgs.fzf
        pkgs.ripgrep
        pkgs.sqlite
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
          "element"
          "orion"
          "discord"
          "whatsapp"
          "utm"
          "signal"
          "zed"
          "drawio"
          "burp-suite"
          "google-chrome"
          "notion"
          "utm"
          "ghidra"
          "ghostty"
          "min"
        ];

        brews= [
          "pkg-config"
          "openjdk@21"
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
          "/System/Applications/Messages.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Launchpad.app"
        ];

        trackpad.Clicking = true;
        finder.AppleShowAllExtensions = true;
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
      system.primaryUser = "i5-650";

      # Correction du nom d'utilisateur (il semble qu'il y avait une incohérence)
      users.users.${username}.home = "/Users/${username}";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Intégration de home-manager
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = { pkgs, ... }: {
        # Configuration spécifique à l'utilisateur via home-manager
        programs.starship = {
          enable = true;
          settings = {
            format = ''
╭─ $username$hostname$directory$git_branch$git_commit$git_state$docker_context$package$c$lua$php$python$rust$go$nix_shell$memory_usage$env_var$custom$sudo$cmd_duration$jobs$time$status$os$container
╰─\$ '';
            add_newline = true;
            scan_timeout = 10;
            command_timeout = 100;
          };
        };

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          autosuggestion.enable = true;
          shellAliases = {
            # --- Nix / Darwin / Flake ---
            nix-update = "nix flake update --flake ~/.config/nix";
            nix-clean = "nix store gc && nix-collect-garbage -d";
            nix-doctor = "nix doctor";
            nix-info = "nix-shell -p nix-info --run nix-info";
            nix-edit = "nvim ~/.config/nix";

            # --- Système ---
            freespace = "sudo du -sh ./*";
            ls = "ls --color=auto";
            fls = "ls -lhrtaX";
            grep = "grep --color=auto";

            # --- Flake utilitaire (à adapter) ---
            flake-check = "nix flake check";
            flake-build = "nix build .#";
            flake-repl = "nix repl .";

            # --- Utils ---
            tmp = "cd $(mktemp -d)";
            ftmp = "zed $(mktemp)";
            z = "zellij";
            zls = "zellij ls";
            za = "zellij attach";
          };

          initExtra = ''
            bindkey "^[[1;2C" forward-word
            bindkey "^[[1;2D" backward-word
          '';
        };

        # Activation de home-manager
        home.stateVersion = "23.11"; # Utilisez une version appropriée
          home.sessionVariables = {
            EDITOR = "nvim";
            TERM = "xterm-256color";
          };
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#i5-650
    darwinConfigurations."i5-650" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
            autoMigrate = true;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."i5-650".pkgs;
  };
}
