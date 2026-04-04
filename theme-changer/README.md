# Theme Changer for Helix

This folder contains scripts to automatically update Helix editor themes when the omarchy theme changes.

## Files

- `update-helix-theme.sh`: Updates the Helix config with the appropriate theme.
- `hx-theme-mappings.txt`: Maps Omarchy theme names to Helix theme names.
- `install-omarchy-theme-hook.sh`: Recreates the missing Omarchy `theme-set` hook.

## Setup

1. Install the hook with:

   ```bash
   ~/Repos/my-omarchy-setup/theme-changer/install-omarchy-theme-hook.sh
   ```

2. This recreates `~/.config/omarchy/hooks/theme-set` and points it at `update-helix-theme.sh`.

3. The updater script changes `~/.config/helix/config.toml` to the mapped Helix theme.

4. Reload the config in Helix with `:config-reload`.

## Customization

Edit `hx-theme-mappings.txt` to add or change mappings. Format:

```
omarchy_theme=helix_theme
```

Examples:

- `catppuccin=catppuccin_mocha`
- `dark=term16_dark`

If a theme is not found in the mappings, it defaults to `term16_dark`.

## Supported Themes

The script supports the following Helix themes (add more to `hx-theme-mappings.txt` as needed):

- catppuccin_mocha
- catppuccin_latte
- everforest_dark
- flexoki_light
- gruvbox
- kanagawa
- nord
- rose_pine_dawn
- tokyonight
- term16_dark (fallback)

## Troubleshooting

- If the config doesn't update, check that `~/.config/helix/config.toml` exists and has a `theme = "..."` line.
- Run the script manually: `./update-helix-theme.sh <theme_name>` to test.
- Ensure the script is executable: `chmod +x update-helix-theme.sh`.
