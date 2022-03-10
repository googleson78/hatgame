{
  description = "Hatgame backend";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
  inputs.gomod2nix = {
    url = github:tweag/gomod2nix;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, gomod2nix }: {
    defaultPackage.x86_64-linux =
      let pkgs = nixpkgs.legacyPackages.x86_64-linux.extend gomod2nix.overlay;
      in
      pkgs.buildGoApplication {
        pname = "hatgame";
        version = "0.1";
        src = ./.;
        modules = ./gomod2nix.toml;
      };
  };
}
