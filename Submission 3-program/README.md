This program is a CLI tool that maintains a list of wallpapers and allows changing it by choosing a number or a random one.

This is in preparation for our final project which will be a UI-enabled wallpaper selector similar to this proof-of-concept but with more features.

If the exe doesn't work this can be rebuilt using `nim c nw` in this directory.
The nim SDK can be installed here: https://nim-lang.org/install.html
You may also have to run `nimble install winim` to install the windows API library.

This only works on Windows.

### Usage
* `add "C:/some/path"` -- Add a wallpaper.
* `remove <#>` -- Remove a wallpaper.
* `set <#>` -- Set your wallpaper to that number.
* `random` -- Set your wallpaper to a random one.
* `help` -- This menu.