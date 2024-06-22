{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.vscode;

  vscodePname = cfg.package.pname;
  vscodeVersion = cfg.package.version;

  jsonFormat = pkgs.formats.json { };

  extensionPath = ".vscode-server/extensions";
  userDir = ".vscode-server/data/Machine/";

  keybindingsFilePath = "/mnt/c/Users/Andrea/Appdata/Roaming/Code/User/keybindings.json";

  configFilePath = "${userDir}/settings.json";
  tasksFilePath = "${userDir}/tasks.json";
  snippetDir = "${userDir}/snippets";

  extensionJson = pkgs.vscode-utils.toExtensionJson cfg.extensions;

  mergedUserSettings = cfg.userSettings
    // optionalAttrs (!cfg.enableUpdateCheck) { "update.mode" = "none"; }
    // optionalAttrs (!cfg.enableExtensionUpdateCheck) {
      "extensions.autoCheckUpdates" = false;
    };
in {
  imports = [ ];

  options = {
    programs.vscode.wsl = mkOption {
      type = types.bool;
      default = false;
      description = "Enable WSL installation (does not install any package, integrates settings with Windows).";
    };
  };

  config = mkIf cfg.wsl {
    home.file = mkMerge [
      (mkIf (mergedUserSettings != { }) {
        "${configFilePath}".source =
          jsonFormat.generate "vscode-user-settings" mergedUserSettings;
      })
      (mkIf (cfg.userTasks != { }) {
        "${tasksFilePath}".source =
          jsonFormat.generate "vscode-user-tasks" cfg.userTasks;
      })
      (mkIf (cfg.keybindings != [ ])
        (let dropNullFields = filterAttrs (_: v: v != null);
        in {
          "${keybindingsFilePath}".source =
            jsonFormat.generate "vscode-keybindings"
            (map dropNullFields cfg.keybindings);
        }))
      (mkIf (cfg.extensions != [ ]) (let
        subDir = "share/vscode/extensions";

        # Adapted from https://discourse.nixos.org/t/vscode-extensions-setup/1801/2
        toPaths = ext:
          map (k: { "${extensionPath}/${k}".source = "${ext}/${subDir}/${k}"; })
          (if ext ? vscodeExtUniqueId then
            [ ext.vscodeExtUniqueId ]
          else
            builtins.attrNames (builtins.readDir (ext + "/${subDir}")));
      in if cfg.mutableExtensionsDir then
        mkMerge (concatMap toPaths cfg.extensions
          ++ lib.optional (lib.versionAtLeast vscodeVersion "1.74.0") {
            # Whenever our immutable extensions.json changes, force VSCode to regenerate
            # extensions.json with both mutable and immutable extensions.
            "${extensionPath}/.extensions-immutable.json" = {
              text = extensionJson;
              onChange = ''
                $DRY_RUN_CMD rm $VERBOSE_ARG -f ${extensionPath}/{extensions.json,.init-default-profile-extensions}
                $VERBOSE_ECHO "Regenerating VSCode extensions.json"
                $DRY_RUN_CMD ${getExe cfg.package} --list-extensions > /dev/null
              '';
            };
          })
      else {
        "${extensionPath}".source = let
          combinedExtensionsDrv = pkgs.buildEnv {
            name = "vscode-extensions";
            paths = cfg.extensions;
          };
        in "${combinedExtensionsDrv}/${subDir}";
      }))

      (mkIf (cfg.globalSnippets != { })
        (let globalSnippets = "${snippetDir}/global.code-snippets";
        in {
          "${globalSnippets}".source =
            jsonFormat.generate "user-snippet-global.code-snippets"
            cfg.globalSnippets;
        }))

      (lib.mapAttrs' (language: snippet:
        lib.nameValuePair "${snippetDir}/${language}.json" {
          source = jsonFormat.generate "user-snippet-${language}.json" snippet;
        }) cfg.languageSnippets)
    ];
  };
}
