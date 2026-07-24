# Pasfetch

<p align="center">
  <img src="demopng" alt="Pasfetch Preview" width="600">
</p>

A simple pascal fetch for Unix-like systems.

## Dependencies (build time only)

- `fpc` (Free Pascal Compiler)
- `make` (no explanation needed)

> **Note for NixOS / GNU Guix users:**
> Standard `sudo make install` won't work due to read-only store paths. Use `nix-shell -p fpc gnumake` or `guix shell fpc make` to build locally.

## Installation & Usage

```bash
# Clone the repository
git clone https://github.com/vissorv/pasfetch.git
cd pasfetch

# Build the project
make

# Install system-wide (optional)
sudo/doas make install
```

###  **OS support**
* **Linux**
* Alpine linux, Arch linux, Debian, Devuan, Gentoo, Guix, NixOS, Opensuse, Slackware, Void linux
* All other distributions are supported with a generic penguin logo.

* **BSD**
* Freebsd, Openbsd, Netbsd

####  **Credits**
This project is highly inspired by **[pfetch](https://github.com/dylanaraps/pfetch)** by dylan araps.
