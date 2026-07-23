_: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        global.chord_timeout = 50;
        main = {
          "j+k" = "esc";
          meta = "overload(meta, M-a)";
        };
      };
    };
  };
}
