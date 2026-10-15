{ writers, python3Packages }:
writers.writePython3Bin "obs-toggle-record"
  {
    libraries = [ python3Packages.obsws-python ];
  }
  ''
    import os
    import sys
    import obsws_python as obs

    password = os.environ.get("OBS_PASSWORD")
    if not password:
        path = os.path.expanduser(
            "~/.config/obs-studio/obs-websocket-password.txt"
        )
        try:
            with open(path, encoding="utf-8") as password_file:
                password = password_file.read().strip()
        except FileNotFoundError:
            sys.exit(
                "OBS_PASSWORD is unset and no websocket password file exists"
            )

    client = obs.ReqClient(
        host="localhost", port=4455, password=password
    )
    client.toggle_record()
  ''
