{
  description = "xinput-json: reproduce `xinput list --short` in json";

  inputs = {
    nixpkgs.url = "nixpkgs"; # from nix flake registry

    crane.url = "github:ipetkov/crane";

    fenix = {
      url = "fenix"; # from nix flake registry
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, crane, fenix }:
    let
      inherit (nixpkgs) lib;
      supportedSystems = [
        "x86_64-linux"
      ];
      target = "x86_64-unknown-linux-musl";
      forEachSystem = mkPackages: lib.genAttrs supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          final = self.packages.${system};
          /**
            https://github.com/nix-community/fenix
            https://crane.dev/examples/cross-musl.html
          */
          rustToolchain = with fenix.packages.${system}; combine [
            minimal.cargo
            minimal.rustc
            targets.${target}.latest.rust-std
          ];
          craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
        in
        mkPackages {
          inherit craneLib pkgs final;
        });
    in
    {
      packages = forEachSystem ({ craneLib, pkgs, final }: {
        default = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

          CARGO_BUILD_TARGET = target;
          CARGO_BUILD_RUSTFLAGS = ''
            -C link-arg=-fuse-ld=mold
            -C target-feature=+crt-static
            -l xcb -l Xau -l Xdmcp -l Xext
          ''; ## ^ additional libs to link

          ## link to `pkgs.pkgsStatic`
          buildInputs = with pkgs.pkgsStatic; [
            xorg.libX11
            xorg.libXi
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
            nukeReferences
            mold-wrapped # https://discourse.nixos.org/t/18530
          ];

          ## https://github.com/NixOS/nix/issues/5633#issuecomment-976502133
          postFixup = ''
            nuke-refs $out/bin/*
          '';
        };

        wingcool-bind = pkgs.writeShellApplication {
          name = "xinput-wingcool-bind";
          runtimeInputs = with pkgs; [
            final.default
            jq
            findutils
            xorg.xinput
          ];
          text = builtins.readFile ./scripts/wingcool-bind.sh;
        };
      });

      devShells = forEachSystem ({ craneLib, pkgs, final }: {
        default = craneLib.devShell {
          # extra inputs can be added here
          # cargo and rustc are provided by default.
          packages = [
            # pkgs.ripgrep
          ];
        };
      });
    };

    nixConfig = {
      extra-substituters = [ "https://chezbryan.cachix.org" ];
      extra-trusted-public-keys = [ "chezbryan.cachix.org-1:4n1STyrAtSfRth4sbgUCKfgjtgR8yIy40jIV829Lfow=" ];
    };
}
