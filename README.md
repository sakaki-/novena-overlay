# gentoo-novena-overlay

Gentoo overlay for the [Novena](https://www.kosagi.com/w/index.php?title=Novena_Main_Page) single-board computer

<img src="https://raw.githubusercontent.com/sakaki-/resources/master/kousagi/novena/Kousagi_Novena.jpg" alt="Kousagi Novena" width="250px" align="right"/>

The purpose of this overlay is to provide Gentoo ebuilds shadowing each of [xobs' Novena Debian packages](https://kosagi.com/w/index.php?title=Novena_packaging_overview#Available_packages). At the time of writing, all of the current Debian packages shipped in the standard Novena microSD card image have been ported (please see [here](#status) for further details).

Installation instructions for this overlay may be found [below](#installation).

## List of Provided Ebuilds

The overlay provides the following ebuilds:

### Ebuilds Shadowing xobs Debian Packages

* **[sys-kernel/novena-sources](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/sys-kernel/novena-sources)** ([upstream (xobs)](https://github.com/xobs/linux-novena), [local patchset](https://github.com/sakaki-/novena-kernel-patches))

   Full set of Linux kernel sources, with both the Gentoo and Novena patchsets applied (I have ported xobs' patchset forward from Linux 4.4 to Linux 4.7.2; the resulting [novena-kernel-patches](https://github.com/sakaki-/novena-kernel-patches) are used by this ebuild).  
   
   In effect, a Novena-specific version of [sys-kernel/gentoo-sources](https://packages.gentoo.org/packages/sys-kernel/gentoo-sources).  
   > This source tree contains firmware blobs, and as such, kernels created from it will be "non-libre" (this is true for the kernels of most distributions of course, including the Ko-usagi Debian image).
   
   As is usual with `sys-kernel/<foo>-sources` packages in Gentoo, emerging this will install a patched source tree into `/usr/src/`, but does not actually configure or build the kernel for you. To do that, follow the instructions [below](#build_kernel).
   
   I recommend you also emerge `sys-kernel/linux-firmware` if using this package, so that Bluetooth works.

* **[sys-kernel/novena_hardened-sources](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/sys-kernel/novena_hardened-sources)** ([upstream (xobs)](https://github.com/xobs/linux-novena), [local patchset](https://github.com/sakaki-/novena-kernel-patches))

   As above, but based instead on Gentoo's [sys-kernel/hardened-sources](https://packages.gentoo.org/packages/sys-kernel/hardened-sources), with deblobbing turned on by default (thereby allowing a fully libre kernel to be built). As the Novena has been designed from the ground up to be FOSS-friendly, almost all hardware features work under this kernel; the only exception (which requires run-time-uploaded firmware) being the built-in Bluetooth adaptor (WiFi works, however).  
   
   There are a few points to bear in mind. First, the deblobbing script takes a *long* time to run (this happens only when you `emerge` the package itself, not on any subsequent `make`). Second, if you use the provided `novena_defconfig`, almost all [Grsecurity](https://wiki.gentoo.org/wiki/Hardened/Grsecurity2_Quickstart) features will be *off* by default (you can turn on the ones you want via `make menuconfig` of course). And third, *unlike* its sister `novena-sources`, I do *not* recommend trying to `make` a `novena_hardened-sources` kernel under `distcc`, due to its extensive use of compiler plugins etc. - just build locally with `make -j4 zImage modules` or similar.
   > As with `sys-kernel/novena-sources`, emerging this package will install a patched source tree into `/usr/src/`, but does not actually configure or build the kernel for you. To do that, follow the instructions [below](#build_kernel).

* **[dev-embedded/novena-eeprom](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/novena-eeprom)** ([upstream (xobs)](https://github.com/xobs/novena-eeprom))

   Ebuild for the [`novena-eeprom`](https://github.com/xobs/novena-eeprom) program, which lets you read and modify the contents of your Novena's personality EEPROM (this holds information such as serial number, MAC address, feature set etc.). A manpage is provided.

* **[dev-embedded/novena-eeprom-gui](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/novena-eeprom-gui)** ([upstream (xobs)](https://github.com/xobs/novena-eeprom-gui))

   Ebuild for the [`novena-eeprom-gui`](https://github.com/xobs/novena-eeprom-gui) application, a simple Qt-based tool that allows you to view and modify the Novena's personality EEPROM (much as `novena-eeprom` does). A manpage is provided.

* **[dev-embedded/novena-heirloom](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/novena-heirloom)** ([upstream (xobs)](https://github.com/xobs/novena-heirloom))

   This package provides support files for the minor extra hardware included with the 'Heirloom' laptop version of the Novena SBC (e.g., the internal fan).  
   
   It should _not_ be installed by Novena desktop, (regular) laptop or 'just the board' users.
 
* **[dev-embedded/novena-usb-hub](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/novena-usb-hub)** ([upstream (xobs)](https://github.com/xobs/novena-usb-hub))

   This program allows you to list the current devices attached to various USB ports, and turn power to these ports on and off. A service is provided to ensure correct power-on behaviour at system start, as well as a power-management hook to handle suspend and resume. A manpage is provided.  
   > Please note that while I have packaged this for both OpenRC and systemd on Gentoo, the systemd variant has not yet been tested.  
   Once emerged, if using OpenRC, you need to:  
   ```console
   # rc-update add novena-usb-hub default
   ```  
   to add this service to the boot sequence.
   If using systemd, issue:
   ```console
   # systemctl enable novena-usb-hub
   ```
   instead.

* **[dev-embedded/u-boot-novena](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/u-boot-novena)** ([upstream (xobs)](https://github.com/xobs/u-boot-novena))

   The `U-Boot` bootloader, with light patches for Novena's DDR3 memory etc.  
   This version creates a first stage bootloader (`u-boot.spl`) plus a main, second-stage bootloader (`u-boot.img`), and installs these into `/usr/share/u-boot-novena/`.
   
   Matching the original Debian package semantics, when emerged this package will also copy `u-boot.{spl,img}` to `/boot` (which must be mounted) and will also install the first stage bootloader (`u-boot.spl`) into the MBR of the Novena's on-board microSD card.  
   
   To enable you to install `u-boot.spl` to the MBR of other microSD cards yourself, a utility program (`novena-install-spl`) is also provided, with manpage.

* **[dev-embedded/update-senoko](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/update-senoko)** ([upstream (xobs)](https://github.com/xobs/senoko-firmware))

   Provides the `update-senoko` utility (and manpage), which may be used to flash firmware onto the Senoko battery/passthrough board on your Novena. Note that, unlike the [senoko-firmware](https://github.com/xobs/senoko-firmware) parent project, this does *not* include bundled firmware blobs. Rather, the ChibiOS firmware for the Senoko board can be easily be built from source, by emerging the `sys-firmware/senoko-chibios` package (see below).

* **[sys-firmware/senoko-chibios](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/sys-firmware/senoko-chibios)** ([upstream (xobs)](https://github.com/xobs/irqbalanced))

   Open-source firmware for the Senoko battery/passthrough board, used in laptop variants of the Novena SBC.  
   
   When emerged, compiles from source the target file `/lib/firmware/senoko.hex`, which may then be flashed to the board using the `update-senoko` utility just described.

* **[media-sound/pulseaudio-novena](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/media-sound/pulseaudio-novena)** ([upstream (xobs)](https://github.com/xobs/pulseaudio-novena))

   Support files for `pulseaudio` on Novena, ensuring that channels are correctly named, that the 'crackly audio' problem is fixed, etc. Note that because Gentoo, unlike Debian, frowns on one package 'diverting' the configuration files (such as `/etc/pulse/default.pa`) owned by another, you must `su` to root, then run:  
   ```console
   # emerge --config pulseaudio-novena
   ```  
   after emerging this package, to finalize the configuration changes, and restart the `pulseaudio` server.

* **[net-wireless/novena-disable-ssp](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/net-wireless/novena-disable-ssp)** ([upstream (xobs)](https://github.com/xobs/novena-disable-ssp))

   All USB Bluetooth >= v2.1 dongles support a feature called [secure simple pairing](https://en.wikipedia.org/wiki/Bluetooth#Bluetooth_v2.1_.2B_EDR), or "SSP". Unfortunately this can cause problems with Bluetooth keyboards, which often fail to reassociate.  
   
   This package provides a small daemon which will monitor all Bluetooth adaptors and disable SSP on them when it sees them. A manpage is provided.  
   > Please note that while I have packaged this for both OpenRC and systemd on Gentoo, the systemd variant has not yet been tested.  
   Once emerged, if using OpenRC, you need to:  
   ```console
   # rc-update add novena-disable-ssp default && service novena-disable-ssp start
   ```  
   to add this service to the boot sequence, and activate it.
   If using systemd, issue:
   ```console
   # systemctl enable novena-disable-ssp && systemctl start novena-disable-ssp
   ```
   instead.

* **[sys-apps/irqbalance-novena](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/sys-apps/irqbalance-novena)** ([upstream (xobs)](https://github.com/xobs/irqbalanced))

   Ebuild for a Novena-specific version of [`irqbalance`](https://github.com/xobs/irqbalanced), which allows interrupts to be farmed out to multiple CPUs. Running the `irqbalance` daemon on the Novena will improve performance (for example, audio stutters less).  
   > Please note that while I have packaged this for both OpenRC and systemd on Gentoo, the systemd variant has not yet been tested.  
   Once emerged, if using OpenRC, you need to:  
   ```console
   # rc-update add irqbalance default && service irqbalance start
   ```  
   to add this service to the boot sequence, and activate it.
   If using systemd, issue:
   ```console
   # systemctl enable irqbalance && systemctl start irqbalance
   ```
   instead.

* **[dev-embedded/etna_viv](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/etna_viv)** ([upstream](https://github.com/etnaviv/etna_viv))

   This is a FOSS user-space driver for the Vivante GCxxx series of embedded GPUs. It is dependency of the `armada` video driver.

* **[x11-libs/libdrm-armada](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/x11-libs/libdrm-armada)** ([upstream](http://git.armlinux.org.uk/~rmk/libdrm-armada.git))

   This library implements the userspace interface to the kernel DRM services, specifically for use with the `armada` X.org video driver (of which it is a dependency).

* **[x11-drivers/xf86-video-armada-novena](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/x11-drivers/xf86-video-armada-novena)** ([upstream (xobs)](https://github.com/xobs/xserver-xorg-video-armada))

   This is a video driver module for the X11 server on the Novena. It supports accelerated drawing through via etnadrm. No firmware uploads or binary blobs in kernel or user space are required. 
   
   As with the current Ko-usagi version, `libgal` support is _not_ enabled.

   If you want this driver, emerge `x11-misc/xorg-novena` (see below); this will install the correct configuration file (and additionally, pull in `x11-drivers/xf86-video-armada-novena` as a dependency).

* **[x11-misc/xorg-novena](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/x11-misc/xorg-novena)** ([upstream (xobs)](https://github.com/xobs/xorg-novena))

   Adds an X.org configuration file to select the 'armada' driver with etnadrm acceleration (this is the current default for shipping Novena boards at the time of writing, and does not rely on galcore, or any firmware, kernel or userspace blobs).

### Utility Ebuilds

* **[sys-devel/portage-distccmon-gui](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/sys-devel/portage-distccmon-gui)**

   Adds a `.desktop` item and wrapper script for `sys-devel/distcc`'s `distccmon-gui` program, so that it is launched with the correct path to view distributed emerges (assuming you are a member of the portage group, or root, and your machine is [correctly set up](https://wiki.gentoo.org/wiki/Distcc) to use `distcc`).

### Metapackage Ebuilds

* **[dev-embedded/novena-meta](https://github.com/sakaki-/gentoo-novena-overlay/tree/master/dev-embedded/novena-meta)**

   This is a convenience metapackage, which you can emerge to pull in the appropriate set of Novena-specific packages (described above) from the overlay. It is customized via the following USE flags:<a name="meta_use_flags"></a>
   
   | USE flag | Default? | Effect |
   | -------- | --------:| ------:|
   | `libre` | No | Omit all non-free software and binary blobs. |
   | `kernel` | No | Pull in the relevant Novena-patched kernel package(s). |
   | `u-boot` | No | Pull in Novena-patched U-Boot, which installs to `/boot` (and MBR). |
   |  `gui` | Yes | Pull in the `armada` X.org driver, and packages with a GUI. |
   | `heirloom` | No | Pull in packages specific to the 'heirloom' laptop. |

## <a name="installation"></a>Installation

These instructions assume you already have a baseline Gentoo Linux installed on your Novena, and (if you wish to use the GUI-based apps), Xfce or similar.

> If you haven't yet installed Gentoo on your Novena, fear not, it is relatively straightforward to do. Please see [this page](https://wiki.gentoo.org/wiki/Novena) on the Gentoo wiki, and also [this post](https://www.kosagi.com/forums/viewtopic.php?id=282) on the Ko-usagi forum. For Xfce on Gentoo, [this wiki article](https://wiki.gentoo.org/wiki/Xfce) is a good starting point. 

Two installations methods are supported - direct installation, or via `layman`. Choose the instructions relevant to your chosen method below. In either case, the name of the installed repository is **gentoo-novena**.

### Direct Installation of the Overlay

This is the preferred method, as of version >= 2.2.16 of Portage, when the [new plug-in sync system](https://wiki.gentoo.org/wiki/Project:Portage/Sync) became available.

The following are short form instructions. If you haven't already installed `git`, do so first:

    # emerge --ask --verbose dev-vcs/git 

Next, create a custom `/etc/portage/repos.conf` entry for the **gentoo-novena** overlay, so Portage knows what to do. Make sure that `/etc/portage/repos.conf` exists, and is a directory. Then, fire up your favourite editor:

    # nano -w /etc/portage/repos.conf/gentoo-novena.conf

and put the following text in the file:
```
[gentoo-novena]

# Overlay for Gentoo on the Novena SBC
# Maintainer: sakaki (sakaki@deciban.com)

location = /usr/local/portage/gentoo-novena
sync-type = git
sync-uri = https://github.com/sakaki-/gentoo-novena-overlay.git
priority = 100
auto-sync = yes
```

Then run:

```console
# emaint sync --repo gentoo-novena
```

(This command can also be run at any time in the future, to pick up changes to the overlay).

Continue reading at 'Completing Installation (Both Methods)', [below](#completing_installation).


### Installation of the Overlay using layman

Make sure that you have `layman` emerged, and that its `git` USE flag is enabled (or that you have `git` emerged separately on your machine).

Add our `repositories.xml` file to the overlays section of /etc/layman/layman.cfg, so it reads:

```
overlays  :
    https://api.gentoo.org/overlays/repositories.xml
    https://raw.githubusercontent.com/sakaki-/gentoo-novena-overlay/master/repositories.xml
```

Update the remote list:

```console
# layman --fetch
```

Now you can add the overlay:

```console
# layman --add gentoo-novena
```

> In the future, to synchronize all overlays and pick up any changes, you can run:
```console
# layman --sync-all
```

Continue with the next section to complete installation.

### <a name="completing_installation"></a>Completing Installation (Both Methods)

If you are running on the stable branch by default, allow **~arm** keyword files from this repository. Make sure that `/etc/portage/package.accept_keywords` exists, and is a directory. Then issue:

```console
# echo "*/*::gentoo-novena ~arm" >> /etc/portage/package.accept_keywords/gentoo-novena-repo
```

Now you can install packages from the overlay! For example:

```console
# emerge --ask --verbose dev-embedded/novena-eeprom
```

To pull in all currently supported packages, you can also issue (make sure to set the appropriate USE flags first, see [above](#meta_use_flags) for details):

```console
# emerge --ask --verbose dev-embedded/novena-meta
```


## <a name="status"></a>Porting Status

As of the time of writing, to the best of my knowledge all of xobs' Debian packages have been ported. If I have missed one, please let me know and I'll add it.

## <a name="build_kernel"></a>Building the Kernel

If you have emerged either `sys-kernel/novena-sources` or `sys-kernel/novena_hardened-sources`, as is usual with Gentoo kernel packages, you still have to configure and build the kernel yourself (the hint is in the 'sources' suffix ^-^). 

> This is different of course from userland packages in Gentoo, where the ebuild takes care of everything for you.

A summary workflow for kernel configuration, build and installation on the Novena is as follows.

First, if you haven't yet done so, emerge the (patched) sources - either:

```console
# emerge -av sys-kernel/novena-sources
```

or:

```console
# emerge -av sys-kernel/novena_hardened-sources
```
as your preference dictates.

Next, select this as the 'current' kernel pointed to by the `/usr/src/linux` symlink. Issue:

```console
# eselect kernel list
```

This displays a numbered list of available kernels. Choose the correct index for your newly emerged kernel in the list. If it was, say, number 2, then issue:

```console
# eselect kernel set 2
```

Grab the default Novena configuration:

```console
# cd /usr/src/linux
# make novena_defconfig
```

Now you can edit the configuration, using `make menuconfig` if you like. Once ready, build the kernel:

```console
# make -j4 zImage modules dtbs
```

This will take some time. If you have [`distcc`](https://wiki.gentoo.org/wiki/Distcc) configured, I strongly recommend you use it (in which case, prefix the `make` with `pump`, and use a higher `-j` value).
> However, I do **not** recommend using `distcc` with `novena_hardened-sources`. This uses compiler plugins etc. so it is generally best built locally.

Now, install the kernel. Assuming your /boot is mounted:
```console
# make modules_install
# cd /boot
# mv zImage{,.bak}
# mv mv novena.dtb{,.bak}
# cp "/usr/src/linux/arch/arm/boot/zImage" .
# cp "/usr/src/linux/arch/arm/boot/dts/imx6q-novena.dtb" novena.dtb
# sync
```

Now simply reboot, and you'll be using your new kernel!

## Feedback Welcome!

If you have any problems, questions or comments regarding this project, feel free to drop me a line! (sakaki@deciban.com)
