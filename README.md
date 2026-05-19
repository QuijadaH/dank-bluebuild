# Dank BlueBuild &nbsp; [![bluebuild build badge](https://github.com/quijadah/bluebuild-hyprland-dms-personal/actions/workflows/build.yml/badge.svg)](https://github.com/quijadah/bluebuild-hyprland-dms-personal/actions/workflows/build.yml)

BlueBuild images with Dank Linux. Only Hyprland available for now.

## TO-DO
- Put instructions from the BlueBuild template into `README.md`.
- Convert the Hypland config to Lua once Dank Linux supports it.
- Maybe format the DMS Keybind Cheatsheet.
- Might add Niri and other Wayland compositors.

## Notes
- The auto-reinstallation of the user-level Flatpaks declared with BlueBuild's `default-flatpaks` module is disabled in the `post-login-setup`, so you can uninstall them without hassle if you want.
- The system-level apps will still be auto-reinstalled since I consider them the "core apps" for Flatpak. Feel free to disable the auto-reinstallation of the system-level Flatpaks by running `bluebuild-flatpak-manager disable system` in the terminal.
- Check out [my personal BlueBuild image](https://github.com/QuijadaH/dank-blue-build-personal) for inspiration or a demonstration.

## `post-login-setup` ([To file](files/system/usr/libexec/dank-blue-build/post-login-setup/run))

> I mainly added this to act as some sort of framework for the various things I usually do after a fresh install.

`post-login-setup` will [automatically run](files/system/etc/skel/.config/autostart/post-login-setup.desktop) a bunch of setup scripts for you after logging in.

You can add your own scripts to [`files/system/usr/libexec/dank-bluebuild/post-login-setup/script.d`](/files/system/usr/libexec/dank-blue-build/post-login-setup/script.d/) for your own convenience post-install or post-rebase.

### Example `post-login-setup` script
```
#!/usr/bin/env bash

set -euo pipefail

abort_script() {
    echo "Script interrupted." >&2
    exit 1
}
trap abort_script INT

# The main setup script relies on the above to function properly.
# You can write whatever you need below.

failed() {
    echo "Failed to execute command." >&2
    exit 1
}

# For non-sudo commands
if [ "$EUID" -ne 0 ]; then
    command || failed
else
    sudo -u "$SUDO_USER" command || failed 
fi

# For sudo commands
if [ "$EUID" -ne 0 ]; then
    sudo command || failed
else
    command || failed 
fi

echo "Successfully executed command."
exit 0
```

## `skel-init.service` ([To file](/files/systemd/system/skel-init.service))

This will initialize Dank Linux's defaults and the autostart of `post-login-setup` for existing users so there won't be too much post-rebase tinkering. Existing and matching config files will be backed up to the same directories for easy recovery.

For newly added users and fresh installs, the nature of `/etc/skel` will automatically initialize its contents into user directories.

## `xdg-terminal-exec` (https://github.com/Vladimir-csp/xdg-terminal-exec)

This is used to set Ghostty as the "fallback terminal emulator" in [`/usr/share/xdg-terminal-exec/xdg-terminals.list`](/files/system/usr/share/xdg-terminal-exec/xdg-terminals.list).

If you decide to install your preferred terminal emulator, please create `xdg-terminals.list` in `/etc/skel/.config` or `~/.config/` and write to it the name of your preferred terminal emulator's `.desktop` file.