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

  outputs = { self, nixpkgs, crane, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        lib = nixpkgs.legacyPackages.${system}.lib;
        crossSystem = lib.systems.examples.musl64;
        localSystem = system;

        pkgs = import nixpkgs {
          inherit localSystem crossSystem;
          overlays = [ (import rust-overlay) ];
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = [ "x86_64-unknown-linux-musl" ];
        };

        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

        my-crate = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

          CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static";
          # CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.llvmPackages.lld}/bin/lld";

          buildInputs = [
            pkgs.pkgsStatic.xorg.libX11
            pkgs.pkgsStatic.xorg.libXi
            # pkgs.pkgsStatic.xorg.libxcb
          ];

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          # Add precompiled library to rustc search path
          RUSTFLAGS = "-l xcb -l Xau -l Xdmcp -l Xext";

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
