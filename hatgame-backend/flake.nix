{
  description = "Hatgame backend";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
  inputs.gomod2nix = {
    url = github:tweag/gomod2nix;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };

  outputs = { self, nixpkgs, gomod2nix, flake-compat }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.extend gomod2nix.overlay;
      buildGoApplication =
        pkgs.buildGoApplication {
          pname = "hatgame";
          version = "0.1";
          src = ./.;
          modules = ./gomod2nix.toml;
        };

    in
    {
      defaultPackage.x86_64-linux = buildGoApplication;
      devShell.x86_64-linux = buildGoApplication //
        pkgs.mkShell {
          # probably needs go fmt etc...
          buildInputs = [ pkgs.go pkgs.gomod2nix ];
          shellHook = ''
            eval "$configurePhase"
          '';
        };

    };
}
