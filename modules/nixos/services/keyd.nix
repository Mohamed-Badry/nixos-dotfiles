_: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" "-0000:0000" ];
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
