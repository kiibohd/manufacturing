# manufacturing
Programs and scripts used in manufacturing

Supports the following flashers:

* Bus Pirate
* Segger JLink


## NOTE

These scripts are intended to be installed as a bundle
The current flashing stations are Arch Linux installs which can be updated with the package.


## Building Package

```bash
cd archpkg
makepkg
```

## Generating Ruby Gem Packages

After installing the kiibohd-manufacturing package.
This requires an internet connection as well as the `pacgem` package to be installed.

```bash
cd /tmp
/usr/local/kiibohd/gemgen.bash
```

Install all packages.
The builds will run again, this time providing you all of the pkgs in the `/tmp/gempkgs` folder.

Remember, these packages may be platform specific. Pay attention to the platform.



# Flashing

Flashing is straight-forward.

* Attach flasher and keyboard to flashing station.
* Run flashing script (e.g. `IC60.flash`)


## Supported Devices

* IC60.flash


## Backend Scripts

Each .flash script calls many other scripts.
In general these are:

* `erase.bash      - #1 Erases chip, runs first.`
* `bootloader.bash - #2 Flashes bootloader using external flasher`
* `firmware.bash   - #3 Flashes firmware using built-in usb flasher`
* `test.bash       - #4 Runs basis QA script`

The `generate.bash` script is used to compile the specific git branch/revision of the bootloader and firmware binary images. This is only used when building the package.

