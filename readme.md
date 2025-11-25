# Nimfinite Wallpapers
by the Nimfinite Nimwits

Using the Nim programming language, this program automates changing the Windows desktop background using the [wNim](https://github.com/khchen/wNim) and [winim](https://github.com/khchen/winim) libraries.

Everything shown in the GUI should work beyond this point.

![Screenshot of the Nimfinite Wallpapers program](https://github.com/JusPSLiu/NimfiniteWallpapers/blob/main/src/example.png)

# 🔧 Creating a Custom Slideshow
The program supports the functionality of creating your own custom slideshow. Simply load your desired images, set each image length, and then play it back with the play button at the bottom of the program.

Slides can be reordered with the `Swap with Next` and `Swap with Previous` buttons, and an image can be replaced with the `Replace Image` button.

In order to set the length, type a number and then press `[enter]` in order to set it. To set the custom slideshow's name, it also does not save unless you press `[enter]`.

If you would like to save this slideshow, simply click the save button on the top right, and save a file of the proprietary `.nimwal` format. The file can then be loaded with the load button which can be located at the top left of the program.

# 🏞️ Wallpaper Presets
This program comes with a couple of wallpaper presets; `Rickroll` and `Bad Apple`.

To use these presets, simply use the dropdown and select one. Note, however, that these presets are predefined and cannot be modified.


# ⚙️ Compiling NimfiniteWallpapers

We provide a `win64 x86_64` build of the executable in releases, but other platforms may have to compile it themselves.

Because of the usage of [wNim](https://github.com/khchen/wNim), this project must be compiled with [Nim 1.4.8](https://nim-lang.org/install.html#:~:text=Nim%201.4:). However, this project uses the atlas project manager, which is available in Nim 2.X.

You must have both a 2.X version of Nim installed and 1.4.8.
In the project root, run
```
C:\Users\<user>\AppData\Local\nim-2.2.6\bin\atlas.exe install
```
to install the dependencies (adjusting for where you have Nim 2.x installed).

After that succeeds, you can then use
```
nim c NimfiniteWallpapers
```
in the root directory to compile it, which will produce a `NimfiniteWallpapers.exe` file which is your primary executable.

Note that this assumes 1.4.8 is in your PATH environment variable. If 2.X is in your PATH, then use the full path to `nim.exe` for the compile command and just `atlas` for the install.

When compiling, verify that you see version 1.4.8 config being used in the compilation.
```
Hint: used config file 'C:\Users\<user>\AppData\Local\nim-1.4.8\config\nim.cfg' [Conf]
Hint: used config file 'C:\Users\<user>\AppData\Local\nim-1.4.8\config\config.nims' [Conf]
```

The executable must be ran within the root directory to have access to the needed image assets.
