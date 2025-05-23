# NixOS Configuration Guide

## Build Commands
- `sudo nixos-rebuild switch --flake .#aarch64-linux` - Build and switch for ARM64 Linux
- `nix flake update` - Update dependencies
- `nix shell nixpkgs#<package>` - Try a package without installing

## Lint Commands
- GitHub Actions runs Statix lint (`lint.yml`)
- Local linting tools: statix, deadnix, nixd, ruff, black, isort, stylua, prettierd, selene

## Code Style
- Follow standard Nix formatting practices
- Use structured modular approach with flakes
- Mimic existing code patterns in each module
- For new components, examine neighboring files for convention
- Python: black/isort/ruff, Lua: stylua/selene, JS: prettierd

## Repository Structure
- `/hosts/` - Host-specific configurations
- `/modules/` - Shared, Darwin, and NixOS-specific modules
- `/overlays/` - Nix overlays (auto-loaded)
- `/config/` - Application-specific configurations

## Guidelines
- Check existing files before introducing dependencies
- Verify imports and code style from context
- Never commit secrets or keys
- I'm using flakes

## Environment Details
- Nix version 2.24.13
