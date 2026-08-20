# Security

No secrets in this repo.

Things that touch credentials:

- `obs-toggle-record` reads the OBS WebSocket password from `$OBS_PASSWORD` or `~/.config/obs-studio/obs-websocket-password.txt`, not from the Nix store.
- Desktop app credentials (Mailspring, browser, Git HTTPS) are stored in GNOME Keyring via the FreeDesktop Secret Service, auto-unlocked on login through PAM.
- Git/Jujutsu identity comes from `flake.nix` host metadata, not a secret.

If you need declarative secret management, use [`sops-nix`](https://github.com/Mic92/sops-nix) or [`agenix`](https://github.com/ryantm/agenix).
