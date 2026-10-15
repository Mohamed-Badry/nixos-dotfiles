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
      };
    };
  };
}
