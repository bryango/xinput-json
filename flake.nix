{
  description = "Build a cargo project with crane";

  inputs = {
    nixpkgs.url = "nixpkgs";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        lib = nixpkgs.legacyPackages.${system}.lib;

        ## compile static binary
        ## https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md
        ## https://n8henrie.com/2023/09/crosscompile-rust-for-x86-linux-from-m1-mac-with-nix/
        pkgs = import nixpkgs {
          inherit system;
          crossSystem = let
              musl64 = lib.systems.examples.musl64;
            in {
              config = musl64.config;
              rustc.config = musl64.config;
              isStatic = true;
            };
        };

        craneLib = crane.mkLib pkgs;

        my-crate = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

          CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static";

          buildInputs = [
            # additional build inputs here
            pkgs.xorg.libX11
            pkgs.xorg.libXi
          ];

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          # MY_CUSTOM_VAR = "some value";
        };
      in
      {
        checks = {
          inherit my-crate;
        };

        packages.default = my-crate;

        apps.default = flake-utils.lib.mkApp {
          drv = my-crate;
        };

        devShells.default = craneLib.devShell {
          # inherit inputs from checks.
          checks = self.checks.${system};

          # MY_CUSTOM_DEVELOPMENT_VAR = "something else";

          # extra inputs can be added here
          # cargo and rustc are provided by default.
          packages = [
            # pkgs.ripgrep
          ];
        };
      });
}
