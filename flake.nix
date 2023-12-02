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

        ## https://crane.dev/examples/cross-musl.html
        pkgs = import nixpkgs {
          inherit system;
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
          CARGO_BUILD_RUSTFLAGS = ''
            -C target-feature=+crt-static
            -l xcb -l Xau -l Xdmcp -l Xext
          '';  ## ^ additional libs to link

          ## link to `pkgs.pkgsStatic`
          buildInputs = with pkgs.pkgsStatic; [
            xorg.libX11
            xorg.libXi
          ];

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

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

        nixConfig = {
          extra-substituters = [ "https://chezbryan.cachix.org" ];
          extra-trusted-public-keys = [ "chezbryan.cachix.org-1:4n1STyrAtSfRth4sbgUCKfgjtgR8yIy40jIV829Lfow=" ];
        };

      });
}
