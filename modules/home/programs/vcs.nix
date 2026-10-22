{
  lib,
  username,
  fullName ? username,
  email ? null,
  ...
}:
let
  vcsUser = {
    name = fullName;
  }
  // lib.optionalAttrs (email != null) {
    inherit email;
  };
in
{
  programs = {
    git = {
      enable = true;
      settings = {
        user = vcsUser;
        init.defaultBranch = "main";
        core.editor = "hx";
        pull.rebase = true;
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = vcsUser;
        ui = {
          default-command = "log";
          editor = "hx";
        };
        aliases = {
          cat = [
            "util"
            "exec"
            "--"
            "bash"
            "-c"
            ''
              orig=("$@")
              files=()
              while [ "$#" -gt 0 ]; do
                case "$1" in
                  -r=*|--revision=*)
                    ;;
                  -r|--revision|-R|--repository|-T|--template|--config|--config-file)
                    shift
                    ;;
                  -*)
                    ;;
                  *)
                    files+=("$1")
                    ;;
                esac
                shift
              done
              if [ "''${#files[@]}" -gt 0 ]; then
                jj file show "''${orig[@]}" | bat --file-name="''${files[-1]}"
              else
                jj file show "''${orig[@]}"
              fi
            ''
            ""
          ];
        };
      };
    };
  };

  xdg.configFile."fish/completions/jj.fish".text = ''
    complete -c jj -n "__fish_use_subcommand" -f -a "cat" -d "Print file contents with syntax highlighting"
    complete -c jj -n "__fish_seen_subcommand_from cat" -s r -l revision -d "Revision to get file from" -r -f -a "(COMPLETE=fish jj -- jj file show -r "")"
  '';
}
