{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.vscode.wsl;

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
    programs.vscode.wsl = {
      enable = mkEnableOption "Visual Studio Code (WSL)";

      package = mkOption {
        type = types.package;
        default = pkgs.vscode;
        defaultText = literalExpression "pkgs.vscode";
        example = literalExpression "pkgs.vscodium";
        description = ''
          Version of Visual Studio Code to install.
        '';
      };

      enableUpdateCheck = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable update checks/notifications.
        '';
      };

      enableExtensionUpdateCheck = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable update notifications for extensions.
        '';
      };

      userSettings = mkOption {
        type = jsonFormat.type;
        default = { };
        example = literalExpression ''
          {
            "files.autoSave" = "off";
            "[nix]"."editor.tabSize" = 2;
          }
        '';
        description = ''
          Configuration written to Visual Studio Code's
          {file}`settings.json`.
        '';
      };

      userTasks = mkOption {
        type = jsonFormat.type;
        default = { };
        example = literalExpression ''
          {
            version = "2.0.0";
            tasks = [
              {
                type = "shell";
                label = "Hello task";
                command = "hello";
              }
            ];
          }
        '';
        description = ''
          Configuration written to Visual Studio Code's
          {file}`tasks.json`.
        '';
      };

      keybindings = mkOption {
        type = types.listOf (types.submodule {
          options = {
            key = mkOption {
              type = types.str;
              example = "ctrl+c";
              description = "The key or key-combination to bind.";
            };

            command = mkOption {
              type = types.str;
              example = "editor.action.clipboardCopyAction";
              description = "The VS Code command to execute.";
            };

            when = mkOption {
              type = types.nullOr (types.str);
              default = null;
              example = "textInputFocus";
              description = "Optional context filter.";
            };

            # https://code.visualstudio.com/docs/getstarted/keybindings#_command-arguments
            args = mkOption {
              type = types.nullOr (jsonFormat.type);
              default = null;
              example = { direction = "up"; };
              description = "Optional arguments for a command.";
            };
          };
        });
        default = [ ];
        example = literalExpression ''
          [
            {
              key = "ctrl+c";
              command = "editor.action.clipboardCopyAction";
              when = "textInputFocus";
            }
          ]
        '';
        description = ''
          Keybindings written to Visual Studio Code's
          {file}`keybindings.json`.
        '';
      };

      extensions = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression "[ pkgs.vscode-extensions.bbenoist.nix ]";
        description = ''
          The extensions Visual Studio Code should be started with.
        '';
      };

      mutableExtensionsDir = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          Whether extensions can be installed or updated manually
          or by Visual Studio Code.
        '';
      };

      languageSnippets = mkOption {
        type = jsonFormat.type;
        default = { };
        example = {
          haskell = {
            fixme = {
              prefix = [ "fixme" ];
              body = [ "$LINE_COMMENT FIXME: $0" ];
              description = "Insert a FIXME remark";
            };
          };
        };
        description = "Defines user snippets for different languages.";
      };

      globalSnippets = mkOption {
        type = jsonFormat.type;
        default = { };
        example = {
          fixme = {
            prefix = [ "fixme" ];
            body = [ "$LINE_COMMENT FIXME: $0" ];
            description = "Insert a FIXME remark";
          };
        };
        description = "Defines global user snippets.";
      };
    };
  };

  config = mkIf cfg.enable {
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
