type
    WallpaperFrame* = tuple[fileName: string, duration: float]

type
    Wallpaper* = tuple[displayName: string, files: seq[WallpaperFrame]]

proc wp_add_frame*(wp: var Wallpaper, frame: WallpaperFrame, pos: int): void =
    wp.files.insert(frame, pos)

proc wp_delete_frame*(wp: var Wallpaper, pos: int): WallpaperFrame =
    var wpfr: WallpaperFrame = wp.files[pos] 
    wp.files.delete(pos)
    return wpfr

proc wp_get_frame*(wp: var Wallpaper, pos: int): WallpaperFrame =
    return wp.files[pos]

# string format: display_name|[file ct]|[fn1]*[fn2]*[...]*[fnN]
# todo: proc parse(text: string): Wallpaper =
# todo:     return ("", @[])
# todo: 
# todo: proc to_string(wp: Wallpaper): string =
# todo:     return wp.displayName
