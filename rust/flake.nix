# This is a simple deterministic rust development environment
# This exposes Cargo, rustfmt, rust-analyzer and clippy
# This does not allow you to build binaries using nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        # Pick what rust compiler to use
        rustVersion = pkgs.rust-bin.stable.latest.default;
      in {
        devShell = pkgs.mkShell {

          # Everything in this list is added to your path
          buildInputs =
            pkgs.lib.optionals pkgs.stdenv.isDarwin
              (with pkgs.darwin.apple_sdk; [

              # Mac specific crypto libs
              frameworks.CoreFoundation
              frameworks.CoreServices
              frameworks.SystemConfiguration

            ]) ++ [

              # A nice LSP IDE backend
              pkgs.rust-analyzer

              # A very opinionated linter
              pkgs.clippy

              # Adds cargo, rustc and rustfmt
              (rustVersion.override {

                # We need this for rust analyzer to jump to library code
                extensions = [ "rust-src" ];

                # Add foreign compile targets here
                targets = [ "wasm32-unknown-unknown" "x86_64-apple-darwin" "wasm32-wasi" ];
            })
            ];
        };
      });
}
