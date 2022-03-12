{
  description = "Hatgame frontend";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      # elm2nix files
      elmSrcs = import ./elm-srcs.nix;
      registryDat = ./registry.dat;

      # pulled this out here so we can share it with the devShell
      fetchElmDeps = pkgs.elmPackages.fetchElmDeps {
        elmPackages = elmSrcs;
        elmVersion = "0.19.1";
        registryDat = registryDat;
      };

    in
    {
      defaultPackage.x86_64-linux =
        let
          mkDerivation =
            { src
            , name
            , srcdir ? "./src"
            , targets ? [ ]
            , outputJavaScript ? false
            , indexHtml ? ""
            }:
            pkgs.stdenv.mkDerivation {
              inherit name src;

              buildInputs = [ pkgs.elmPackages.elm ]
                ++ pkgs.lib.optional outputJavaScript pkgs.nodePackages.uglify-js;

              buildPhase = fetchElmDeps;

              installPhase =
                let
                  elmfile = module: "${srcdir}/${builtins.replaceStrings ["."] ["/"] module}.elm";
                  extension = if outputJavaScript then "js" else "html";
                in
                ''
                  mkdir -p $out/share/doc
                  ${pkgs.lib.concatStrings (map (module: ''
                    echo "compiling ${elmfile module}"
                    elm make ${elmfile module} --output $out/${module}.${extension} --docs $out/share/doc/${module}.json
                    ${pkgs.lib.optionalString outputJavaScript ''
                      echo "minifying ${elmfile module}"
                      uglifyjs $out/${module}.${extension} --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
                          | uglifyjs --mangle --output $out/${module}.min.${extension}
                    ''}
                  '') targets)}
                  if [[ "${indexHtml}" != "" ]]
                  then
                    cp "./${indexHtml}" "$out/${indexHtml}"
                  fi
                '';
            };
        in
        mkDerivation
          {
            name = "hatgame-frontend";
            src = ./.;
            targets = [ "Main" ];
            srcdir = "./src";
            outputJavaScript = true;
            indexHtml = "index.html";

          };

      devShell.x86_64-linux = pkgs.mkShell {
        packages = [
          pkgs.elm2nix
          pkgs.elmPackages.elm
          pkgs.elmPackages.elm-format
          pkgs.elmPackages.elm-test
          pkgs.elmPackages.elm-language-server
        ];
        shellHook = fetchElmDeps;
      };

    };
}
