{ pkgs, inputs, ... }: {
  programs.vscode = {
    profiles.default.userSettings = {
      # "editor.letterSpacing" = -0.3;
      # "editor.fontSize" = 13.16;
      # "terminal.integrated.fontFamily" = "Fira Code";
      "editor.fontFamily" = inputs.iwi-consolas.name;
      "terminal.integrated.fontFamily" = inputs.iwi-dejavu.name;
      "terminal.integrated.fontSize" = 13;

      "editor.fontLigatures" = true;
      "editor.glyphMargin" = false;

      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      "editor.hover.delay" = 250;
      "editor.inlineSuggest.enabled" = true;
      "editor.insertSpaces" = true;
      "editor.lineHeight" = 1.30;
      "editor.linkedEditing" = true;
      "editor.minimap.maxColumn" = 60;
      "editor.minimap.scale" = 2;
      "editor.mouseWheelZoom" = false;
      "editor.smoothScrolling" = true;
      "editor.stickyScroll.enabled" = true;
      "editor.suggest.localityBonus" = true;
      "editor.suggest.preview" = true;
      "editor.tabSize" = 2;
      "editor.inlayHints.enabled" = "off";
      "editor.accessibilitySupport" = "off";
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
      "security.workspace.trust.untrustedFiles" = "open"; # Does not work from WSL
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.cursorStyle" = "line";
      "terminal.integrated.enableMultiLinePasteWarning" = "never";
      "terminal.integrated.rightClickBehavior" = "copyPaste";
      "terminal.integrated.scrollback" = 10000;
      "terminal.integrated.smoothScrolling" = true;
      "terminal.integrated.mouseWheelZoom" = true;
      "terminal.integrated.defaultProfile.linux" = "fish"; # Needed on WSL
      "update.mode" = "none";
      "window.menuBarVisibility" = "hidden";
      "window.zoomLevel" = 1;
      "window.confirmSaveUntitledWorkspace" = false;
      "workbench.editor.splitSizing" = "split";
      "workbench.editor.tabSizing" = "shrink";
      "workbench.list.smoothScrolling" = true;
      "workbench.startupEditor" = "none";
      "workbench.tree.indent" = 16;
      "workbench.tree.renderIndentGuides" = "always";
      # "workbench.activityBar.location" = "hidden";
      "editor.suggest.showWords" = false;
      # Rust
      "rust-analyzer.inlayHints.typeHints.enable" = false;
      # Copilot
      "github.copilot.editor.enableCodeActions" = false;
      # Nix
      "nix.enableLanguageServer" = true;
      "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nixEnvSelector.nixShellPath" = "nix develop";
      # Idris
      "idris.idris2Mode" = true;
      "idris.idrisPath" = "idris2";
      # Agda
      "agdaMode.view.panelMountPosition" = "right";
      "agdaMode.connection.commandLineOptions" = "+RTS -M16G";
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
      "[latex]" = {
        "editor.wordWrap" = "bounded";
        "editor.wordWrapColumn" = 80;
      };
      "files.associations" = {
        "*.tikz" = "latex";
        "*.tikzstyles" = "latex";
      };
      "latex-workshop.latex.autoBuild.run" = "onSave";
      "latex-workshop.latex.autoClean.run" = "onBuilt";
      "latex-workshop.latex.recipe.default" = "lastUsed";
      "latex-workshop.view.pdf.viewer" = "tab";
      "latex-workshop.latex.recipes" = [
        { "name" = "latexmk";           "tools" = [ "latexmk"   ]; }
        { "name" = "latexmk (xelatex)"; "tools" = [ "xelatexmk" ]; }
        { "name" = "pdflatex";          "tools" = [ "pdflatex"  ]; }
        { "name" = "xelatex";           "tools" = [ "xelatex"   ]; }
      ];
      "latex-workshop.latex.tools" = [
        { "command" = "latexmk";  "env" = {}; "name" = "latexmk";   "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-pdf" "-f" "%DOC%" ]; }
        { "command" = "latexmk";  "env" = {}; "name" = "xelatexmk"; "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-xelatex"  "%DOC%" ]; }
        { "command" = "pdflatex"; "env" = {}; "name" = "pdflatex";  "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "%DOC%" ]; }
        { "command" = "xelatex";  "env" = {}; "name" = "xelatex";   "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "%DOC%" ]; }
      ];
      "workbench.editor.empty.hint" = "hidden";
      "workbench.editor.autoLockGroups" = {
        "latex-workshop-pdf-hook" = true;
        "mainThreadWebview-markdown.preview" = true;
      };
    };
    profiles.default.keybindings = [

      # Movement

      { "command" = "cursorDown";                "key" = "ctrl+alt+s";             }
      { "command" = "cursorDown";                "key" = "ctrl+k";                 }
      { "command" = "cursorDownSelect";          "key" = "ctrl+shift+k";           }
      { "command" = "cursorLeft";                "key" = "ctrl+alt+j";             }
      { "command" = "cursorLeft";                "key" = "ctrl+alt+a";             }
      { "command" = "cursorWordLeftSelect";      "key" = "ctrl+shift+j";           }
      { "command" = "cursorRight";               "key" = "ctrl+alt+l";             }
      { "command" = "cursorRight";               "key" = "ctrl+alt+d";             }
      { "command" = "cursorWordRightSelect";     "key" = "ctrl+shift+l";           }
      { "command" = "cursorUp";                  "key" = "ctrl+alt+w";             }
      { "command" = "cursorUp";                  "key" = "ctrl+i";                 }
      { "command" = "cursorDown";                "key" = "ctrl+k";                 }
      { "command" = "cursorWordPartLeft";        "key" = "ctrl+j";                 }
      { "command" = "cursorLeftSelect";          "key" = "ctrl+alt+shift+j";       }
      { "command" = "cursorWordPartRight";       "key" = "ctrl+l";                 }
      { "command" = "cursorRightSelect";         "key" = "ctrl+alt+shift+l";       }

      { "command" = "cursorRightSelect";         "key" = "ctrl+shift+l";           }
      { "command" = "cursorUpSelect";            "key" = "ctrl+shift+i";           }
      { "command" = "cursorWordPartDownSelect";  "key" = "ctrl+shift+k";           }
      { "command" = "cursorWordPartLeftSelect";  "key" = "ctrl+shift+j";           }

      { "command" = "deleteWordLeft";            "key" = "ctrl+h";                 }
      { "command" = "deleteWordPartLeft";        "key" = "ctrl+shift+h";           }
      { "command" = "deleteWordPartRight";       "key" = "ctrl+shift+[semicolon]"; }
      { "command" = "deleteWordRight";           "key" = "ctrl+[semicolon]";       }

      { "command" = "cursorLeft";                "key" = "ctrl+alt+j";             }
      { "command" = "cursorRight";               "key" = "ctrl+alt+l";             }
      { "command" = "cursorWordPartLeftSelect";  "key" = "ctrl+alt+shift+j";       }
      { "command" = "cursorWordPartRightSelect"; "key" = "ctrl+alt+shift+l";       }

      { "command" = "deleteLeft";                "key" = "ctrl+alt+h";             }
      { "command" = "deleteRight";               "key" = "ctrl+alt+[semicolon]";   }

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
      { "command" = "editor.action.triggerSuggest";              "key" = "ctrl+space ctrl+space"; "when" = "!editorHasSelection"; }

      { "command" = "removeSecondaryCursors";                    "key" = "ctrl+w";                "when" = "multiCursorModifier"; }

      { "command" = "editor.action.startFindReplaceAction";      "key" = "ctrl+f";                "when" = "!findWidgetVisible";  }
      { "command" = "closeFindWidget";                           "key" = "ctrl+f";                "when" = "findWidgetVisible";   }
      { "command" = "workbench.action.replaceInFiles";           "key" = "ctrl+shift+f";          "when" = "";                    }

      { "command" = "editor.action.indentLines";                 "key" = "tab";                   "when" = "editorHasSelection";  }
      { "command" = "editor.action.outdentLines";                "key" = "shift+tab";             "when" = "editorHasSelection";  }

      # Windows

      { "command" = "workbench.action.closeActiveEditor";        "key" = "ctrl+w";                "when" = "!editorHasSelection"; }
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
      { "command" = "workbench.action.togglePanel";              "key" = "ctrl+space ctrl+c";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.action.toggleSidebarVisibility";  "key" = "ctrl+space ctrl+e";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.files.action.focusFilesExplorer"; "key" = "ctrl+space ctrl+d";     "when" = "!editorHasSelection"; }
      { "command" = "workbench.action.files.showOpenedFileInNewWindow"; "key" = "ctrl+space ctrl+t"; "when" = "!editorHasSelection"; }

      { "command" = "workbench.action.reopenClosedEditor";       "key" = "ctrl+shift+t";                                          }
      { "command" = "workbench.action.reopenTextEditor";         "key" = "ctrl+space ctrl+t";                                     }

      { "command" = "editor.action.toggleWordWrap";              "key" = "ctrl+space w";          "when" = "";                    }

      # Menus

      { "command" = "selectNextSuggestion"; "key" = "ctrl+k"; "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"; }
      { "command" = "selectPrevSuggestion"; "key" = "ctrl+i"; "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"; }

      # Agda mode

      { "command" = "agda-mode.auto[AsIs]";                                        "key" = "ctrl+a ctrl+q";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.case";                                              "key" = "ctrl+a ctrl+c";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.compile";                                           "key" = "ctrl+a ctrl+-";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.give";                                              "key" = "ctrl+a ctrl+space"; "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.goal-type-context-and-inferred-type[Instantiated]"; "key" = "ctrl+a ctrl+g";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.goal-type-context-and-inferred-type[Simplified]";   "key" = "ctrl+a ctrl+f";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.goal-type-context-and-inferred-type[Normalised]";   "key" = "ctrl+a ctrl+s";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.load";                                              "key" = "ctrl+a ctrl+d";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.lookup-symbol";                                     "key" = "ctrl+a ctrl+l";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.previous-goal";                                     "key" = "ctrl+a ctrl+w";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.next-goal";                                         "key" = "ctrl+a ctrl+z";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.refine";                                            "key" = "ctrl+a ctrl+r";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.restart";                                           "key" = "ctrl+a ctrl+t";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.solve-constraints[Normalised]";                     "key" = "ctrl+a ctrl+x";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.show-constraints";                                  "key" = "ctrl+a ctrl+v";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.switch-agda-version";                               "key" = "ctrl+a ctrl+b";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.toggle-display-of-implicit-arguments";              "key" = "ctrl+a ctrl+m";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.toggle-display-of-irrelevant-arguments";            "key" = "ctrl+a ctrl+n";     "when" = "editorLangId == 'agda'"; }
      { "command" = "agda-mode.input-symbol[Activate]";                            "key" = "oem_5";             "when" = "editorLangId == 'agda'"; }
    ];
    # https://github.com/nix-community/nix-vscode-extensions/issues/99#issuecomment-2703326753
    profiles.default.extensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
      ms-vscode-remote.remote-wsl
      banacorn.agda-mode
      adpyke.codesnap
      bbenoist.nix
      jnoortheen.nix-ide
      haskell.haskell
      justusadam.language-haskell
      dart-code.dart-code
      denoland.vscode-deno
      #eamodio.gitlens
      github.copilot
      james-yu.latex-workshop
      meraymond.idris-vscode
      ms-vscode.wordcount
      ms-vsliveshare.vsliveshare
      rust-lang.rust-analyzer
      yo1dog.cursor-align
      rubymaniac.vscode-direnv
    ];
  };
}
