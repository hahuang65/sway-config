# sway

My personal configuration for [sway](https://github.com/swaywm/sway)
I will do my best to comment the configuration file. Feel free to crib/steal this for your own personal use.

## Usage

Run `./install.sh` to link the configuration files to the proper location

## Nvidia

Roughly taken from [Hyprland Docs](https://wiki.hyprland.org/Nvidia/)

1. Install Nvidia drivers: `pacman -S nvidia`
2. Add `nvidia_drm.modeset=1` to the bottom of `/boot/loader/entries/arch.conf`
3. Add `nvidia nvidia_modeset nvidia_uvm nvidia_drm` to the `MODULES` section of `/etc/mkinitcpio.conf`
4. Remove `kms` from the `HOOKS` section of `/etc/mkinitcpio.conf`
5. Re-build initramfs: `mkinitcpio -P`
6. Add `options nvidia-drm modeset=1` to `/etc/modprobe.d/nvidia.conf` (create file if non-existent)
7. Add the pacman [hook](https://wiki.archlinux.org/title/NVIDIA#pacman_hook) to regenerate initramfs when `nvidia` or `linux` is updated
8. Install `vulkan-validation-layers` if Sway refuses to start with `ERROR_LAYER_NOT_PRESENT (-6)`
