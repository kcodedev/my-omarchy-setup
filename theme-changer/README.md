# Theme Changer for Helix

This folder contains scripts to automatically update Helix editor themes when the omarchy theme changes.

## Files

- `update-helix-theme.sh`: The main script that updates the Helix config with the appropriate theme.
- `theme-mappings.txt`: A key-value file mapping omarchy theme names to Helix theme names.

## Setup

1. Ensure your omarchy theme switcher has a hook script (e.g., `theme-set`) that runs on theme changes. The hook is located at `~/.config/omarchy/hooks/theme-set`.

2. Add the following line to your `theme-set` hook script:

   ```bash
   ~/Repos/my-omarchy-setup/theme-changer/update-helix-theme.sh "$1"
   ```

   Adjust the path if your repo is cloned elsewhere.

3. The script will update `~/.config/helix/config.toml` with the matching theme.

4. Manually reload the config in Helix by running `:config-reload` in the editor.

## Customization

Edit `theme-mappings.txt` to add or change mappings. Format:

```
omarchy_theme=helix_theme
```

Examples:

- `catppuccin=catppuccin_mocha`
- `dark=term16_dark`

If a theme is not found in the mappings, it defaults to `term16_dark`.

## Supported Themes

The script supports the following Helix themes (add more to `theme-mappings.txt` as needed):

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