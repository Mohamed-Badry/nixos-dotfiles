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

clean:
    sudo nix-env --delete-generations +5 -p /nix/var/nix/profiles/system
    sudo nix-collect-garbage
    nix-collect-garbage
