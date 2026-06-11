# NixOS Dotfiles

"I use Nix btw"

![System Showcase](pics/demo.png)

---

## Core Stack

| Component | Choice | Description |
| :--- | :--- | :--- |
| OS | NixOS | Declarative, reproducible Linux distribution |
| Window Manager | dwm | Fast, compact, dynamic window manager |
| Terminal | st | Simple terminal implementation for X |
| Status Bar | dwmblocks | Modular, script-driven status monitor |
| Display Manager | ly | TUI display manager for Linux and BSD |
| Compositor | picom | Lightweight compositor for X11 |
| Input Method | fcitx5 | Flexible input method framework |

---

## Repository Structure

```text
.
├── flake.lock
├── flake.nix                  # Flake entrypoint (defines hosts, inputs, and outputs)
├── hosts/                     # Machine-specific configurations
│   ├── nixbox1/               # Host 1 configuration directory
│   │   ├── configuration.nix  # System-level configurations
│   │   ├── hardware-configuration.nix
│   │   └── home/              # Home Manager environments
│   │       └── anon.nix       # User-space dotfiles and packages
│   └── nixbox2/               # Host 2 configuration directory
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── home/
│           └── anon.nix
├── modules/                   # Shared configurations and system profiles
│   ├── pkgs/                  # Nix derivation profiles for custom software
│   │   ├── dwmblocks.nix
│   │   ├── dwm.nix
│   │   ├── slock.nix
│   │   └── st.nix
│   └── utils/                 # Extensible, reusable system modules
│       ├── docker.nix         # Docker daemon setup
│       ├── i18n.nix           # Internationalization and language settings
│       ├── nvidia.nix         # Modern NVIDIA proprietary graphics
│       ├── nvidia-pre-turing.nix # Legacy NVIDIA drivers
│       ├── qemu.nix           # Virtualization and QEMU support
│       └── tailscale.nix      # Zero-config mesh VPN configuration
├── pics/                      # Wallpapers, assets, and documentation images
│   ├── demo.png
│   └── wallpaper1.png
└── src/                       # Raw C source code for patched Suckless tools
    ├── dwm/                   # Custom Window Manager source and patches
    ├── dwmblocks/             # Status Bar source and modular status scripts
    ├── slock/                 # Minimal screen locker source
    └── st/                    # Terminal emulator source and patches

## Core Stack

- **OS:** NixOS
- **Window Manager:** dwm
- **Terminal:** st
- **Bar:** dwmblocks
- **Display Manager:** ly
- **Compositor:** picom
- **Input Method:** fcitx5

---

## Usage & Deployment

### Apply Configuration

Rebuild and apply the system configuration for a specific host:

```bash
# For nixbox1
sudo nixos-rebuild switch --flake .#nixbox1

# For nixbox2
sudo nixos-rebuild switch --flake .#nixbox2
```

### Add a New Host

1. Duplicate an existing host directory:

```bash
cp -r hosts/nixbox1 hosts/your-hostname
```

2. Update hardware details in:

```text
hosts/your-hostname/hardware-configuration.nix
```

3. Edit `configuration.nix` for your machine's config (e.g. bootloader, system packages, users etc):

```nix
networking.hostName = "your-hostname";
```

4. Register the host in `flake.nix`:

```nix
hosts = {
  nixbox1 = { users = [ "anon" ]; };
  nixbox2 = { users = [ "anon" ]; };
  your-hostname = { users = [ "anon" ]; };
};
```

5. Deploy:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

---

## Updating Packages (Flakes)

1. **Update flake inputs**:

```bash
nix flake update
```

This will fetch the latest versions of channels, nixpkgs, and other inputs defined in your `flake.nix`.

2. **Rebuild and apply updated configuration**:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```
---

## Maintenance & Cleanup

Nix retains historical generations so you can rollback at any time.

To permanently purge old generations and optimize disk space:

```bash
nix-collect-garbage -d
sudo nix-collect-garbage -d
nix store optimise
```
