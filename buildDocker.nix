{ pkgs ? import <nixpkgs> { }
, pkgsLinux ? import <nixpkgs> { system = "x86_64-linux"; }
}:

let
  nixos = pkgs.dockerTools.pullImage {
    imageName = "nixos/nix";
    imageDigest = "sha256:fc55b9bf9f61742a3fc262c0dc9ad62ea8ace014bb5bd4b11341da879e7b26ce";
    sha256 = "1aa7adr0g2pa12zj4h7zcsg63222yqp7204vpwd6c2xjfw1hv44a";
    finalImageName = "nixos/nix";
    finalImageTag = "latest";
  };

in
pkgs.dockerTools.buildImage {
  name = "hatgame";
  fromImage = nixos;
  config = {
    Cmd = [ ];
  };
}
