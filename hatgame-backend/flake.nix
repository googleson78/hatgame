{
  description = "Hatgame backend";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
  inputs.gomod2nix.url = github:tweag/gomod2nix;

  outputs = { self, nixpkgs, gomod2nix }: {
    defaultPackage.x86_64-linux =
      let pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ gomod2nix.overlay ]; };
      in
      pkgs.buildGoApplication {
        pname = "hatgame";
        version = "0.1";
        src = ./.;
        modules = ./gomod2nix.toml;
      };
  };
}
