{
  description = "Build a cargo project with crane";

  inputs = {
    nixpkgs.url = "nixpkgs";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        craneLib = crane.lib.${system};
        my-crate = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

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
