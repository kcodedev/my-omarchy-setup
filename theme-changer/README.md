# Omarchy Theme Mappings

Omarchy renders `~/.config/omarchy/current/theme/helix.toml` from the active
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
- preserves Omarchy's `themes/omarchy.toml` symlink
- repairs the old deleted hook-based integration if it is still installed
- refreshes the current Omarchy theme

Edit `hx-theme-mappings.txt` to change Helix mappings.

## Zellij

Zellij does not read Omarchy's generated Helix theme, so the Zellij installer
uses the Catppuccin Zellij theme definitions from Luke Hsiao's dotfiles plus
compatible built-in Zellij themes, and keeps Zellij's active `theme "..."`
directive in sync with Omarchy.

The important detail for light themes is that `catppuccin-latte` uses a light
`black` slot and dark `white` slot. Zellij uses those names for UI ribbons and
status surfaces, not just terminal ANSI colors, so this avoids the muddy
dark-theme contrast that shows up when Helix is light but Zellij is still dark.

Run:

```bash
./theme-changer/install-omarchy-zellij-theme-mapping.sh
```

The installer:

- writes `~/.config/zellij/themes/catppuccin.kdl`
- maps the current Omarchy theme to a Zellij Catppuccin variant
- maps Omarchy themes such as `everforest`, `gruvbox`, `kanagawa`, `nord`,
  and `tokyo-night` to close built-in Zellij equivalents
- uses Zellij's built-in `ansi` theme as the generic fallback so unmatched
  Omarchy themes can follow the terminal palette
- adds an idempotent `theme-set` hook so future Omarchy theme changes update
  `~/.config/zellij/config.kdl`

Edit `zellij-theme-mappings.txt` to change Zellij mappings.
