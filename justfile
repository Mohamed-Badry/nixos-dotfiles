set dotenv-load := false

host := "nixos"

default:
    @just --list

check:
    nix flake check --no-build --all-systems

fmt:
    nix fmt

lint:
    statix check .

develop:
    nix develop

test:
    sudo nixos-rebuild test --flake .#{{host}}

switch:
    sudo nixos-rebuild switch --flake .#{{host}}

boot:
    sudo nixos-rebuild boot --flake .#{{host}}

build:
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

update:
    nix flake update
