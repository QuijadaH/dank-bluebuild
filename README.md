# Dank BlueBuild &nbsp; [![bluebuild build badge](https://github.com/quijadah/bluebuild-hyprland-dms-personal/actions/workflows/build.yml/badge.svg)](https://github.com/quijadah/bluebuild-hyprland-dms-personal/actions/workflows/build.yml)

BlueBuild images with Dank Linux. Only Hyprland available for now.

## Installation

### Rebase

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build of `dank-bluebuild-hyprland`:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/quijadah/dank-bluebuild-hyprland:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/quijadah/dank-bluebuild-hyprland:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

### ISO

> I will provide pre-built ISOs soon via SourceForge.

> Make sure you have the [BlueBuild CLI tool](https://github.com/blue-build/cli) installed. On Windows, I installed the tool using [its GitHub install script](https://github.com/blue-build/cli#github-install-script) on a Docker-integrated WSL 2 instance.

To install `dank-bluebuild-hyprland` from an ISO, you must first run the following command to build an ISO:
```
sudo bluebuild generate-iso --iso-name weird-os.iso image ghcr.io/quijadah/dank-bluebuild-hyprland
```

Then you can flash the ISO using [Fedora Media Writer](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/#_fedora_media_writer).


### Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/quijadah/dank-bluebuild-hyprland
```

---

## Features

### `skel-init.service` ([To file](/files/systemd/system/skel-init.service))

> I added this because I thought it would be a hassle to create and configure the needed dotfiles after rebasing. Although BlueBuild has a `chezmoi` module, I thought using it just to initialize some default configurations was unnecessary.

This will initialize Dank Linux's defaults and the autostart of `post-login-setup` for existing users so there won't be too much post-rebase tinkering. Existing and matching config files will be backed up to the same directories for easy recovery.

For a new user from a fresh install or that was manually added, the nature of `/etc/skel` will automatically initialize the contents of their home directory.

### `post-login-setup` ([To file](files/system/usr/libexec/dank-bluebuild/post-login-setup/run))

> I mainly added this to act as some sort of framework for the various things I usually do after a fresh install.

This will [automatically run](files/system/etc/xdg/autostart/post-login-setup.desktop) a bunch of [setup scripts](/files/system/usr/libexec/dank-bluebuild/post-login-setup/script.d/) for you after logging in.

This setup scripts in this image do the following:
- Disable the auto-reinstallation of default user Flatpaks.
    - Allows you to uninstall the pre-installed user Flatpaks.
- Disable `skel-init.service` after it runs once.
    - Makes sure that `skel-init.service` won't accidentally interfere with your home directory.
- Sync DankGreeter to the user theme.
    - For a more consistent aesthetic.

You can add your own scripts to `files/system/usr/libexec/dank-bluebuild/post-login-setup/script.d` for your own convenience post-install or post-rebase.

#### Example `post-login-setup` script
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

### `xdg-terminal-exec` (https://github.com/Vladimir-csp/xdg-terminal-exec)

This is used to set Ghostty as the "fallback terminal emulator" via [`files/system/usr/share/xdg-terminal-exec/xdg-terminals.list`](/files/system/usr/share/xdg-terminal-exec/xdg-terminals.list).

If you decide to install your preferred terminal emulator, please create `xdg-terminals.list` in `files/system/etc/skel/.config/` or `~/.config/` and write to it the name of your preferred terminal emulator's `.desktop` file.

---

### TO-DO
- Convert the Hypland config to Lua once Dank Linux supports it.
- Maybe format the DMS Keybind Cheatsheet.
- Might add Niri and other Wayland compositors.

### Notes
- The system-level apps (Warehouse and Flatseal) will still be auto-reinstalled since I consider them the "core apps" for Flatpak. You can disable the auto-reinstallation of the system-level Flatpaks by running `bluebuild-flatpak-manager disable system` in the terminal.
- Check out [my personal BlueBuild image](https://github.com/QuijadaH/dank-bluebuild-personal) for inspiration or a demonstration.