# Dank BlueBuild &nbsp; [![bluebuild build badge](https://github.com/quijadah/dank-bluebuild/actions/workflows/build.yml/badge.svg)](https://github.com/quijadah/bluebuild-hyprland-dms-personal/actions/workflows/build.yml)

Not too opinionated [BlueBuild](https://blue-build.org/) image~~s~~ with [Dank Linux](https://danklinux.com/). Only [Hyprland](https://hypr.land/) available for now.

Dank BlueBuild is heavily inspired by [wayblue](https://github.com/wayblueorg/wayblue/) and aims to be pretty much like wayblue if it had Dank Linux. It started off as a personal project that I didn't intend to share publicly, but I later thought that maybe there would be someone who would appreciate a readily-available Fedora Atomic image with Dank Linux.

> [!IMPORTANT]
> A good chunk of the QoL features development was AI-assisted since I only had surface-level knowledge of Bash and had knew nothing about Systemd units. Once I learned enough about Bash from the back-and-forth with ChatGPT, I manually cleaned up the main script and wrote the setup scripts myself.

> ### PLANS
> - Provide pre-built ISOs via SourceForge.
> - Convert the Hypland config to Lua once Dank Linux supports it.
> - Use BlueBuild's Flatpak module once it supports Flatpak Preinstall.
> - Add Niri and other Wayland compositors someday.

## Quality of Life Features

### [`skel-init`](files/system/usr/libexec/dank-bluebuild/skel-init/run)

> I added this because I thought it would be a hassle to manually create and edit the needed dotfiles after rebasing. Although BlueBuild has a [`chezmoi` module](https://blue-build.org/reference/modules/chezmoi/), I thought using it just to initialize some default configurations was overkill.

This script will [run only once on boot](files/systemd/system/skel-init.service) to initialize Dank Linux's defaults for existing users in an effort to reduce post-rebase tinkering. The script does this by copying the contents of `/etc/skel` to the user directories. Existing config files will be backed up to the same directories for easy recovery.

For a new user from a fresh install or that was manually added, the nature of `/etc/skel` will automatically initialize the contents of their home directory.

To let `skel-init` run again, delete the `run.completed` file in `/var/lib/dank-bluebuild/skel-init/` and then reboot.

### [Flatpak Preinstall](https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-preinstall)

> I got the idea to use this Flatpak feature instead of BlueBuild's own `default-flatpaks` module from this [feature request for said module](https://github.com/blue-build/modules/issues/494). I will use the module once the feature is supported; for now, we'll have to make do with 

### [`post-login-setup`](files/system/usr/libexec/dank-bluebuild/post-login-setup/run)

This is a framework that will run a bunch of [setup scripts](/files/system/usr/libexec/dank-bluebuild/post-login-setup/script.d/) for the user [automatically after logging in](files/system/etc/xdg/autostart/post-login-setup.desktop).

The only setup script included in Dank BlueBuild is [`sync-dankgreeter`](files/system/usr/libexec/dank-bluebuild/post-login-setup/script.d/sync-dankgreeter) which syncs your user theme to [DankGreeter](https://danklinux.com/docs/dankgreeter) using [`dms greeter sync`](https://danklinux.com/docs/dankgreeter/installation#2-sync-with-your-user-theme). However, you can [add your own scripts](#add-on-setup-scripts-for-post-login-setup) in `.../post-login-setup/script.d/`.

> [!NOTE]
> Scripts to disable the Flatpak setups and `skel-init` services used to be part of `post-login-setup`, but I eventually thought that letting them disable themselves with Systemd's own directives was cleaner. Let me know if explicitly disabling them in `post-login-setup` is better.

## Installation

### Available Images

> All images include [`core-modules.yml`](recipes/common/core-modules.yml), which adds Dank Linux, the [Dank BlueBuild features](#features), and other core software and functions.
>
> Window manager-specific images include the module for their respective WM alongside the core module.
>
> Non-minimal images also include [`common-modules.yml`](recipes/common/common-modules.yml), which adds a bunch of GUI apps and useful utilities for an OOTB experience. 

| Image | Recipe |
|---|---|
| `dank-bluebuild-hyprland` | [`recipe-hyprland.yml`](recipes/recipe-hyprland.yml) |
| `dank-bluebuild-hyprland-minimal` | [`recipe-hyprland-minimal.yml`](recipes/recipe-hyprland-minimal.yml) |

### Rebase

> [!WARNING]
> BlueBuild: [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build of a Dank BlueBuild image (e.g. `dank-bluebuild-hyprland`):

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

> [!IMPORTANT]
> Make sure you have the [BlueBuild CLI tool](https://github.com/blue-build/cli) installed.

> [!NOTE]
> On Windows, I installed the BlueBuild CLI tool using [its GitHub install script](https://github.com/blue-build/cli#github-install-script) on a Docker-integrated WSL 2 instance. Maybe you could try this for yourself.

To install a Dank BlueBuild image (e.g. `dank-bluebuild-hyprland`) from an ISO, you must first run the following command to build an ISO:
```
sudo bluebuild generate-iso --iso-name dank-bluebuild-hyprland.iso image ghcr.io/quijadah/dank-bluebuild-hyprland
```

Then you can flash the ISO using [Fedora Media Writer](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/#_fedora_media_writer).


### Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/quijadah/dank-bluebuild-hyprland
```

## Customization

It is recommended that you [set up a new repository](https://blue-build.org/how-to/setup/) based on [`blue-build/template`](https://github.com/blue-build/template) and use a Dank BlueBuild image as the base for your [recipe](https://blue-build.org/reference/recipe/#base-image-required). This is so you can add your customizations on top of Dank BlueBuild instead of directly configuring it, such that you only need to maintain your own customizations and not constantly update your recipe to sync with Dank BlueBuild's.

> Check out [my personal BlueBuild image](https://github.com/QuijadaH/personal-dank-bluebuild) to see how I built my own custom image on top of Dank BlueBuild.

### About Terminal Emulators

`xdg-terminal-exec` is used to set Ghostty as the "fallback terminal emulator", so Dank BlueBuild recommends not removing Ghostty from your recipe. Instead, add your preferred terminal emulator to your recipe and set it as the default.

To set a default terminal emulator, please create `xdg-terminals.list` in [`/etc/skel/.config/`](files/system/etc/skel/.config) or `~/.config/` and write to it the name of your preferred terminal emulator's `.desktop` file.

If you really want to get rid of Ghostty, then make sure to edit [`/usr/share/xdg-terminal-exec/xdg-terminals.list`](files/system/usr/share/xdg-terminal-exec/xdg-terminals.list) accordingly.

### Add-on setup scripts for `post-login-setup`

You can add your own setup scripts in [`/usr/libexec/dank-bluebuild/post-login-setup/script.d/`](files/system/usr/libexec/dank-bluebuild/post-login-setup/script.d/) for your own convenience post-install or post-rebase.

#### Example `post-login-setup` add-on script
```
#!/usr/bin/env bash

set -euo pipefail

on_interrupt() {
    trap - INT TERM
    echo "Script interrupted." >&2
    exit 130
}
trap on_interrupt INT TERM

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

### Disable QoL Features

Simply disable `skel-init.service` and create the file `/etc/dank-bluebuild/post-login-setup/auto.disabled` in your own recipe via BlueBuild's [`systemd`](https://blue-build.org/reference/modules/systemd/) and [`script`](https://blue-build.org/reference/modules/script/) modules respectively. You can also add said file directly into your repo's `files/` directory.

```
modules:
  - type: systemd
    system:
      disabled:
        - skel-init.service

  - type: script
    snippets:
      - "mkdir -p /etc/dank-bluebuild/post-login-setup"
      - "touch /etc/dank-bluebuild/post-login-setup/auto.disabled"
```

### Hyprland User Configs Directory

Instead of creating your own `hyprland.conf` with your preferences, Dank BlueBuild recommends putting your own Hyprland configs in `/etc/skel/.config/hypr/user/` or `~/.config/hypr/user/`. The default [`hyprland.conf`](files/hyprland/etc/skel/.config/hypr/hyprland.conf) that comes with Dank BlueBuild's Hyprland images sources `./user/*` at the very end of the file so that your configs take precedence over the default config and the DMS overrides. This is to separate your own configs from the base default config such that whatever breaks in the base config is Dank BlueBuild's to fix, and whatever breaks in your configs is yours to fix. Additionally, organizing your configs this way makes it easier to maintain. Such is the magic of modularization.
