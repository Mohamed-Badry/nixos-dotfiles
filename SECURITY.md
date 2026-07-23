# Security and secrets

No secrets should be committed to this repository.

Current secret-adjacent behavior:

- `obs-toggle-record` reads the OBS websocket password from `OBS_PASSWORD` or `~/.config/obs-studio/obs-websocket-password.txt`.
- Git and Jujutsu identity are supplied from host metadata in `flake.nix`; no real email address is required by default.
- Noctalia settings are rendered from a checked-in template and copied writable because Noctalia mutates its JSON settings at runtime.

If this configuration grows real secrets, use a dedicated Nix secret manager such as `sops-nix` or `agenix`, and keep encrypted secret material separate from host-independent modules.
