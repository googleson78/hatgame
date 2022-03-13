{ config, lib, pkgs, ... }:

let
  cfg = config.services.hatgameBackend;
  hatgame =
    builtins.fetchGit
      {
        url = "https://github.com/googleson78/hatgame.git";
        ref = "nixify";
      };
  hatgameBackend = (import "${hatgame}/hatgame-backend").default;
in
{
  options.services.hatgameBackend = {
    enable = lib.mkEnableOption "hatgameBackend";
  };

  config = lib.mkIf cfg.enable {

    services.postgresql = {
      enable = true;
      port = 5432;
      authentication = ''
        host all all localhost trust
      '';
      ensureDatabases = [ "hatgamedb" ];
      ensureUsers = [
        {
          name = "mypguser";
          ensurePermissions = {
            "DATABASE hatgamedb" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    systemd.services.hatgameBackend =
      let
        runDir = "hatgame";
        workDir = "/run/${runDir}";
      in
      {
        after = [
          "network.target"
        ];
        description = "Hatgame backend";
        startLimitIntervalSec = 0;
        script =
          let psqlinfo =
            {
              host = "localhost";
              port = 5432;
              user = "mypguser";
              dbname = "hatgamedb";
              password = "asdf";
              sslmode = "disable";
            };
          in
          ''
            ${pkgs.coreutils}/bin/echo '${builtins.toJSON psqlinfo}' > ${workDir}/psqlInfo.json
            ${hatgameBackend}/bin/hatgame
          '';
        wantedBy = [
          "multi-user.target"
        ];
        environment = { };
        serviceConfig = {
          Type = "exec";
          Restart = "always";
          RestartSec = 1;
          User = "root";

          RuntimeDirectory = runDir;
          WorkingDirectory = workDir;
        };
      };
  };
}
