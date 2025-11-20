type
    WallpaperFrame* = tuple[fileName: string, duration: float]

type
    Wallpaper* = tuple[displayName: string, files: seq[WallpaperFrame], length:int]

proc wp_add_frame*(wp: var Wallpaper, frame: WallpaperFrame, pos: int): void =
    wp.files.insert(frame, pos)
    wp.length+=1

proc wp_replace_frame*(wp: var Wallpaper, file: string, pos: int): void =
    if (pos < 0 or pos >= wp.length):
        return
    wp.files[pos].fileName = file

proc wp_change_duration*(wp: var Wallpaper, duration: float, pos: int): void =
    if (pos < 0 or pos >= wp.length):
        return
    wp.files[pos].duration = duration

proc wp_swap_frame_with_next*(wp: var Wallpaper, pos: int): void =
    if (pos < 0 or pos >= wp.length-1):
        return
    # temp
    let l_name = wp.files[pos].fileName
    let l_duration = wp.files[pos].duration
    # set L
    wp.files[pos].fileName = wp.files[pos+1].fileName
    wp.files[pos].duration = wp.files[pos+1].duration
    # set R
    wp.files[pos+1].fileName = l_name
    wp.files[pos+1].duration = l_duration

proc wp_delete_frame*(wp: var Wallpaper, pos: int): WallpaperFrame =
    var wpfr: WallpaperFrame = wp.files[pos] 
    wp.files.delete(pos)
    wp.length-=1
    return wpfr

proc wp_get_frame*(wp: var Wallpaper, pos: int): WallpaperFrame =
    return wp.files[pos]

proc wp_get_frame_file*(wp: var Wallpaper, pos: int) : string = 
    if (pos < 0 or pos >= wp.length):
        return ""
    return wp_get_frame(wp, pos).fileName
