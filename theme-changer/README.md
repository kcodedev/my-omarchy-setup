# Omarchy Theme Mappings

Omarchy renders `~/.local/state/omarchy/current/theme/helix.toml` from the active
theme palette and symlinks it into Helix as `themes/omarchy.toml`.

This setup keeps that native integration, but changes each Omarchy theme's
generated `helix.toml` to inherit from a chosen built-in Helix theme. Themes
without a close Helix equivalent fall back to `term16_dark`.

## Usage

Run:

```bash
./theme-changer/install-omarchy-helix-theme-mapping.sh
```

The installer:

- writes per-theme overlays into `~/.config/omarchy/themes/<theme>/helix.toml`
- points Helix at `theme = "omarchy"`
- preserves Omarchy's `themes/omarchy.toml` symlink to the state directory
- repairs the old deleted hook-based integration if it is still installed
- refreshes the current Omarchy theme

Edit `hx-theme-mappings.txt` to change Helix mappings.
