{ config, pkgs, nix-vscode-extensions, ... }: {
  home.stateVersion = "23.05";
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "flakes" "nix-command" ];
  };
  home.packages = with pkgs; [
    texlive.combined.scheme-full
    (agda.withPackages [ agdaPackages.standard-library agdaPackages.agda-categories ])
    zip
    unzip
    neofetch
    ack
    dua       # Disk usage analyzer
    gource    # SVC visualization
    hyperfine # Command-line benchmarking tool
    pv        # Monitor the progress of data through a pipe
    nixfmt
  ];
  programs.direnv  = { enable = true; nix-direnv.enable = true; };
  #programs.atuin   = { enable = true; enableFishIntegration = true; };
  programs.zoxide  = { enable = true; enableFishIntegration = true; };
  programs.ssh     = { enable = true; package = pkgs.openssh; addKeysToAgent = "yes"; };
  programs.ripgrep = { enable = true; };
  programs.btop    = { enable = true; };
  programs.bat     = { enable = true; };
  programs.eza     = { enable = true; };
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    userName  = "iwilare";
    userEmail = "iwilare@gmail.com";

    extraConfig.color.ui = true;
    extraConfig.core.askPass = "";
    extraConfig.core.fileMode = true;
    extraConfig.credential.helper = "store";
    extraConfig.github.user = "iwilare";
    extraConfig.init.defaultBranch = "main";
    extraConfig.pull.rebase = false;
    extraConfig.push.autoSetupRemote = true;
    extraConfig.url."https://github.com/".insteadOf = [ "gh:" "github:" ];
    extraConfig.commit.gpgsign = true;
    extraConfig.gpg.format = "ssh";
    extraConfig.user.signingKey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC070EeFAV0Uj5OSrIeSzPn7oj/Vr3Rj5eXAA13c/iug iwilare@gmail.com";
  };
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt.body = ''printf "λ %s%s%s> " (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)'';
      nix-run = "nix run nixpkgs#$argv[1] -- $argv[2..]";
    };
    shellInit = ''set fish_greeting'';
    shellAbbrs = {
      m  = { expansion = "git commit -am '%'"; setCursor = true; };
      ns = { expansion = "nix shell nixpkgs#%"; setCursor = true; };
      gs = { expansion = "git remote set-url origin git@github.com:iwilare/%"; setCursor = true; };
      gg = { expansion = "git clone git@github.com:$argv[1]"; setCursor = true; };
    };
    shellAliases = {
      c  = "bat -p"; # -p[lain] (use as cat)
      w  = "ack -il";
      l  = "eza --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type";
      la = "eza --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type --all";
      t  = "eza --icons --tree -s=type --all";
      ta = "eza --icons --tree -s=type";

      s = "git status";
      gp = "git push";
      gd = "git diff";
      gl = "git log --pretty=format:'%C(auto) %h %ci [%an] %s%d' --graph";
      gu = "git remote add origin ''; git remote set-url origin git@github.com:iwilare/(basename $PWD)";
      save = "git commit -am (date '+%Y-%m-%d %H:%M:%S') && git push";

      nd = "nextd";
      pd = "prevd";
      diff = "diff-so-fancy";

      nr = "nix-run";
      no = "code /etc/nixos/";
      nos = "sudo nixos-rebuild switch";
      hm = "code ~/.config/home-manager";
      hmd = "cd ~/.config/home-manager";
      hms = "home-manager switch -b backup";
    };
    plugins = [
      # {
      #   name = "z";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "jethrokuan";
      #     repo = "z";
      #     rev = "85f863f";
      #     sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      #   };
      # }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (oldAttrs: rec { version = "stable"; });
    userSettings = {
      # "editor.letterSpacing" = -0.3;
      # "editor.fontFamily" = "'${iwi-font}'";
      # "editor.fontSize" = 13.16;
      "editor.fontLigatures" = true;
      "editor.glyphMargin" = false;

      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      "editor.hover.delay" = 250;
      "editor.inlineSuggest.enabled" = true;
      "editor.insertSpaces" = true;
      "editor.linkedEditing" = true;
      "editor.minimap.maxColumn" = 60;
      "editor.minimap.scale" = 2;
      "editor.smoothScrolling" = true;
      "editor.stickyScroll.enabled" = true;
      "editor.suggest.localityBonus" = true;
      "editor.suggest.preview" = true;
      "editor.tabSize" = 2;
      "explorer.compactFolders" = false;
      "explorer.confirmDragAndDrop" = false;
      "explorer.incrementalNaming" = "smart";
      "explorer.sortOrderLexicographicOptions" = "upper";
      "files.eol" = "\n";
      "files.insertFinalNewline" = true;
      "files.restoreUndoStack" = true;
      "files.simpleDialog.enable" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
      "liveshare.notebooks.allowGuestExecuteCells" = true;
      "search.smartCase" = true;
      "search.sortOrder" = "fileNames";
      "security.workspace.trust.enabled" = false;
      "security.workspace.trust.untrustedFiles" = "open";
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.cursorStyle" = "line";
      "terminal.integrated.enableMultiLinePasteWarning" = false;
      "terminal.integrated.rightClickBehavior" = "copyPaste";
      "terminal.integrated.scrollback" = 10000;
      "terminal.integrated.smoothScrolling" = true;
      "terminal.integrated.defaultProfile.linux" = "fish"; # Needed on WSL
      "update.mode" = "none";
      "window.menuBarVisibility" = "hidden";
      "workbench.editor.splitSizing" = "split";
      "workbench.editor.tabSizing" = "shrink";
      "workbench.list.smoothScrolling" = true;
      "workbench.startupEditor" = "none";
      "workbench.tree.indent" = 16;
      "workbench.tree.renderIndentGuides" = "always";
      # Idris
      "idris.idris2Mode" = true;
      "idris.idrisPath" = "idris2";
      # Agda
      "agdaMode.view.panelMountPosition" = "right";
      "[agda]" = {
        "editor.unicodeHighlight.ambiguousCharacters" = false;
      };
      # Dart
      "[dart]" = {
        "editor.formatOnSave" = true;
        "editor.formatOnType" = true;
        "editor.rulers" = [
          80
        ];
        "editor.selectionHighlight" = false;
        "editor.suggest.snippetsPreventQuickSuggestions" = false;
        "editor.suggestSelection" = "first";
        "editor.tabCompletion" = "onlySnippets";
      };
      # LaTeX
      "files.associations" = {
        "*.tikz" = "latex";
        "*.tikzstyles" = "latex";
      };
      "latex-workshop.latex.autoBuild.run" = "onSave";
      "latex-workshop.latex.autoClean.run" = "onBuilt";
      "latex-workshop.latex.recipe.default" = "lastUsed";
      "latex-workshop.view.pdf.viewer" = "tab";
      "latex-workshop.latex.recipes" = [
        { "name" = "latexmk (xelatex)"; "tools" = [ "xelatexmk" ]; }
        { "name" = "latexmk";           "tools" = [ "latexmk"   ]; }
        { "name" = "pdflatex";          "tools" = [ "pdflatex"  ]; }
        { "name" = "xelatex";           "tools" = [ "xelatex"   ]; }
      ];
      "latex-workshop.latex.tools" = [
        { "command" = "latexmk";  "env" = {}; "name" = "xelatexmk"; "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-xelatex"  "-draftmode" "%DOC%" ]; }
        { "command" = "latexmk";  "env" = {}; "name" = "latexmk";   "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-pdf" "-f" "-draftmode" "%DOC%" ]; }
        { "command" = "pdflatex"; "env" = {}; "name" = "pdflatex";  "args" = [ "-synctex=1" "-outdir=%OUTDIR%" "-draftmode" "%DOC%" ]; }
        { "command" = "xelatex";  "env" = {}; "name" = "xelatex";   "args" = [ "-synctex=1" "-outdir=%OUTDIR%" "-draftmode" "%DOC%" ]; }
      ];
      "workbench.editor.empty.hint" = "hidden";
      "workbench.editor.autoLockGroups" = {
        "latex-workshop-pdf-hook" = true;
        "mainThreadWebview-markdown.preview" = true;
      };
    };
    keybindings = [

      # Movement

      { "command" = "cursorDown";                "key" = "ctrl+k";                 }
      { "command" = "cursorDownSelect";          "key" = "ctrl+shift+k";           }
      { "command" = "cursorLeft";                "key" = "ctrl+alt+j";             }
      { "command" = "cursorLeftSelect";          "key" = "ctrl+shift+j";           }
      { "command" = "cursorRight";               "key" = "ctrl+alt+l";             }
      { "command" = "cursorRightSelect";         "key" = "ctrl+shift+l";           }
      { "command" = "cursorUp";                  "key" = "ctrl+i";                 }
      { "command" = "cursorUpSelect";            "key" = "ctrl+shift+i";           }

      { "command" = "cursorWordPartLeft";        "key" = "ctrl+j";                 }
      { "command" = "cursorWordPartLeftSelect";  "key" = "ctrl+alt+shift+j";       }
      { "command" = "cursorWordPartRight";       "key" = "ctrl+l";                 }
      { "command" = "cursorWordPartRightSelect"; "key" = "ctrl+alt+shift+l";       }

      { "command" = "deleteLeft";                "key" = "ctrl+alt+h";             }
      { "command" = "deleteRight";               "key" = "ctrl+alt+[semicolon]";   }
      { "command" = "deleteWordLeft";            "key" = "ctrl+h";                 }
      { "command" = "deleteWordPartLeft";        "key" = "ctrl+shift+h";           }
      { "command" = "deleteWordPartRight";       "key" = "ctrl+shift+[semicolon]"; }
      { "command" = "deleteWordRight";           "key" = "ctrl+[semicolon]";       }

      { "command" = "cursorHome";                "key" = "ctrl+q";                 }
      { "command" = "cursorHomeSelect";          "key" = "ctrl+alt+q";             }
      { "command" = "cursorLineEnd";             "key" = "ctrl+e";                 }
      { "command" = "cursorLineEndSelect";       "key" = "ctrl+alt+e";             }

      # Selection

      { "command" = "expandLineSelection";                       "key" = "ctrl+m";                                           }
      { "command" = "editor.action.smartSelect.expand";          "key" = "ctrl+r";                                           }
      { "command" = "editor.action.smartSelect.shrink";          "key" = "ctrl+shift+r";      "when" = "editorHasSelection"; }
      { "command" = "editor.action.moveLinesUpAction";           "key" = "ctrl+alt+i";        "when" = "editorHasSelection"; }
      { "command" = "editor.action.moveLinesDownAction";         "key" = "ctrl+alt+k";        "when" = "editorHasSelection"; }
      { "command" = "cancelSelection";                           "key" = "ctrl+w";            "when" = "editorHasSelection"; }
      { "command" = "editor.action.selectHighlights";            "key" = "ctrl+space ctrl+d";                                }
      { "command" = "editor.action.selectAll";                   "key" = "ctrl+space ctrl+a";                                }

      # Clipboard and undoing

      { "command" = "editor.action.clipboardCutAction";          "key" = "ctrl+x";            "when" = "editorHasSelection"; }
      { "command" = "editor.action.clipboardCopyAction";         "key" = "ctrl+c";            "when" = "editorHasSelection"; }
      { "command" = "editor.action.clipboardPasteAction";        "key" = "ctrl+v";                                           }
      { "command" = "redo";                                      "key" = "ctrl+alt+z";                                       }
      { "command" = "undo";                                      "key" = "ctrl+z";                                           }
      { "command" = "cursorRedo";                                "key" = "ctrl+space ctrl+u";                                }

      # Multi cursor

      { "command" = "yo1dog.cursor-align.alignCursors";          "key" = "ctrl+t";                                                }
      { "command" = "editor.action.insertCursorAbove";           "key" = "ctrl+alt+i";            "when" = "!editorHasSelection"; }
      { "command" = "editor.action.insertCursorBelow";           "key" = "ctrl+alt+k";            "when" = "!editorHasSelection"; }
      { "command" = "editor.action.insertLineBefore";            "key" = "ctrl+alt+enter";                                        }
      { "command" = "editor.action.insertLineAfter";             "key" = "ctrl+enter";                                            }
      { "command" = "editor.action.copyLinesDownAction";         "key" = "ctrl+alt+c";                                            }
      { "command" = "editor.action.selectHighlights";            "key" = "ctrl+shift+d";                                          }
      { "command" = "editor.action.startFindReplaceAction";      "key" = "ctrl+alt+f";                                            }
      { "command" = "editor.action.joinLines";                   "key" = "ctrl+g";                "when" = "!editorHasSelection"; }
      { "command" = "editor.action.commentLine";                 "key" = "ctrl+b";                                                }
      { "command" = "editor.action.triggerSuggest";              "key" = "ctrl+y";                "when" = "!editorHasSelection"; }
      { "command" = "removeSecondaryCursors";                    "key" = "ctrl+;";                "when" = "multiCursorModifier"; }
      { "command" = "editor.action.startFindReplaceAction";      "key" = "ctrl+space ctrl+f";     "when" = "!editorHasSelection"; }
      { "command" = "editor.action.triggerSuggest";              "key" = "ctrl+space ctrl+space"; "when" = "!editorHasSelection"; }

      { "command" = "removeSecondaryCursors";                    "key" = "ctrl+;";                "when" = "multiCursorModifier"; }

      # { "command" = "editor.action.deleteLines";                 "key" = "ctrl+n";                                              }
      # { "command" = "editor.action.indentLines";                 "key" = "tab";                "when" = "editorHasSelection";   }
      # { "command" = "editor.action.outdentLines";                "key" = "shift+tab";          "when" = "editorHasSelection";   }

      # Windows

      { "command" = "workbench.action.closeActiveEditor";        "key" = "ctrl+space ctrl+w";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.action.closeActiveEditor";        "key" = "ctrl+w";                "when" = "multiCursorModifier"; }
      { "command" = "workbench.action.files.newUntitledFile";    "key" = "ctrl+space ctrl+s";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.action.files.openFile";           "key" = "ctrl+o";                                                }
      { "command" = "workbench.action.files.openFileFolder";     "key" = "ctrl+space ctrl+o";                                     }
      { "command" = "workbench.action.previousEditor";           "key" = "ctrl+space ctrl+1";                                     }
      { "command" = "workbench.action.nextEditor";               "key" = "ctrl+space ctrl+2";                                     }
      { "command" = "workbench.action.openEditorAtIndex1";       "key" = "ctrl+1";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex2";       "key" = "ctrl+2";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex3";       "key" = "ctrl+3";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex4";       "key" = "ctrl+4";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex5";       "key" = "ctrl+5";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex6";       "key" = "ctrl+6";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex7";       "key" = "ctrl+7";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex8";       "key" = "ctrl+8";                "when" = "";                    }
      { "command" = "workbench.action.openEditorAtIndex9";       "key" = "ctrl+9";                "when" = "";                    }
      { "command" = "workbench.action.quickOpen";                "key" = "ctrl+p";                                                }
      { "command" = "workbench.action.togglePanel";              "key" = "ctrl+space ctrl+q";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.action.toggleSidebarVisibility";  "key" = "ctrl+space ctrl+e";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.files.action.focusFilesExplorer"; "key" = "ctrl+space ctrl+d";     "when" = "!editorHasSelection"; }

      # Menus

      { "command" = "selectNextSuggestion"; "key" = "ctrl+k"; "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"; }
      { "command" = "selectPrevSuggestion"; "key" = "ctrl+i"; "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"; }

      # Agda mode

      { "command" = "agda-mode.auto";                                              "key" = "ctrl+a ctrl+q";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.case";                                              "key" = "ctrl+a ctrl+c";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.compile";                                           "key" = "ctrl+a ctrl+-";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.compute-normal-form[DefaultCompute]";               "key" = "ctrl+a ctrl+e";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.give";                                              "key" = "ctrl+a ctrl+space"; "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.goal-type-context-and-inferred-type[Instantiated]"; "key" = "ctrl+a ctrl+g";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.goal-type-context-and-inferred-type[Normalised]";   "key" = "ctrl+a ctrl+s";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.goal-type-context-and-inferred-type[Simplified]";   "key" = "ctrl+a ctrl+f";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.load";                                              "key" = "ctrl+a ctrl+d";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.lookup-symbol";                                     "key" = "ctrl+a ctrl+l";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.next-goal";                                         "key" = "ctrl+a ctrl+z";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.previous-goal";                                     "key" = "ctrl+a ctrl+w";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.refine";                                            "key" = "ctrl+a ctrl+r";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.restart";                                           "key" = "ctrl+a ctrl+p";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.restart";                                           "key" = "ctrl+a ctrl+t";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.show-constraints";                                  "key" = "ctrl+a ctrl+v";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.switch-agda-version";                               "key" = "ctrl+a ctrl+b";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.toggle-display-of-implicit-arguments";              "key" = "ctrl+a ctrl+m";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.toggle-display-of-irrelevant-arguments";            "key" = "ctrl+a ctrl+n";     "when" = "editorLangId == 'agda'"; }
    ];
    extensions = with nix-vscode-extensions.extensions."x86_64-linux".vscode-marketplace; [
      ms-vscode-remote.remote-wsl
      banacorn.agda-mode
      adpyke.codesnap
      bbenoist.nix
      jnoortheen.nix-ide
      haskell.haskell
      justusadam.language-haskell
      dart-code.dart-code
      denoland.vscode-deno
      eamodio.gitlens
      github.copilot
      james-yu.latex-workshop
      meraymond.idris-vscode
      ms-vscode.wordcount
      ms-vsliveshare.vsliveshare
      rust-lang.rust-analyzer
      yo1dog.cursor-align
    ];
  };
}
