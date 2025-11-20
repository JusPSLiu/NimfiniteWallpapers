import wNim/[wApp, wFrame, wPanel, wBitmap, wStaticBox, wStaticBitmap, wStaticText,
  wButton, wComboBox, wTextCtrl, wSlider, wFileDialog, wImage]
import std/[times, os], strutils  # for strings, time and os
import winim
import wallpaper_set
#import threads # for multithreading

# enums because enums
type
  switchmode = enum
    mode_left, mode_set, mode_right
  preset = enum
    enum_preset
    enum_custom

# consts
let RESOURCE_DIRECTORY = getCurrentDir() & "\\src\\"
let RESOURCE_DIRECTORY_CSTR : cstring = RESOURCE_DIRECTORY

# custom vars to adjust throughout development to test
var slideshow_index = 0
var slideshow_len = 326
var slideshow_preset = enum_preset
var slideshow_name = "Bad Apple"
var slideshow_name_cstr : cstring = "Bad Apple"
# the default custom slideshow list
var slideshow_list : Wallpaper = default(Wallpaper)
slideshow_list.length = 0
slideshow_list.displayName = "Custom Slideshow"

# the secondary thread
#var thr = new Thread[void]

# Window
let app = App(wSystemDpiAware)
let frame = Frame(title="Nimfinite Wallpapers", style=wDefaultFrameStyle or wModalFrame)
frame.dpiAutoScale:
  frame.size = (640, 660)
  frame.minSize = (500, 630)

# Panels
let panel = Panel(frame)
let staticbox1 = StaticBox(panel, label="Slideshow Loading")
let staticbox2 = StaticBox(panel, label="Edit Slideshow")
let staticbox3 = StaticBox(panel)
let staticbox4 = StaticBox(panel, label="Playback")

# 'Slideshow Loading' Panel
let label_ld = StaticText(panel, label="Custom Slideshow")
let button_ldslides = Button(panel, label="Load Custom Slideshow")
let button_svslides = Button(panel, label="Save Custom Slideshow")
let label_ps = StaticText(panel, label="Slideshow Presets")
let combobox_dfslides = ComboBox(panel, value="Custom",
  choices=["Custom", "Rickroll", "Bad Apple"],
  style=wCbReadOnly)

let label_ename = StaticText(panel, label="Edit Name")
let label_name = StaticText(panel, label="Slideshow", style=wAlignCenter)
let textctrl_name = TextCtrl(panel, value="Slideshow", style=wBorderSunken)

# 'Edit Slideshow' Panel
let framenumber = StaticText(panel, label="Frame 0/0", style=wAlignCenter)
let image = RESOURCE_DIRECTORY & "sample_slideshow\\not_found.png"
let preview = StaticBitmap(panel, bitmap=Bitmap(image), style=wSbFit)
let previewl = StaticBitmap(panel, bitmap=Bitmap(image), style=wSbFit)
let previewr = StaticBitmap(panel, bitmap=Bitmap(image), style=wSbFit)

let label_duration = StaticText(panel, label="Image Duration: (0 seconds)", style=wAlignLeft)
let textctrl_duration = TextCtrl(panel, value="0", style=wBorderSunken)
let preview_slider = Slider(panel, value=0, range=0..slideshow_len, style=wSlAutoTicks or wSlTop)
preview_slider.setTickFreq(1)
let button_l = Button(panel, label="<")
let button_r = Button(panel, label=">")
let button_lm = Button(panel, label="|<")
let button_rm = Button(panel, label=">|")

let button_replace = Button(panel, label="Replace Image")
let button_insert = Button(panel, label="Insert Image(s)")
let button_swn = Button(panel, label="Swap with Next")
let button_swp = Button(panel, label="Swap with Previous")
let button_del = Button(panel, label="Delete Image")

# 'Playback' panel
let button_play = Button(panel, label="Play Slideshow")
var playing : bool = false


proc enableEditing(enable : bool = true) =
  if (enable):
    button_svslides.enable()
    textctrl_name.enable()
    button_insert.enable()
    if (slideshow_list.length > 0):
      button_replace.enable()
      button_del.enable()
    if (slideshow_index < slideshow_len): button_swn.enable()
    if (slideshow_index > 0): button_swp.enable()
  else:
    button_svslides.disable()
    textctrl_name.disable()
    button_replace.disable()
    button_insert.disable()
    button_swn.disable()
    button_swp.disable()
    button_del.disable()

proc changeName(newname : string) =
  slideshow_name = newname
  slideshow_name_cstr = newname
  label_name.setLabel(newname)
  textctrl_name.setValue(newname)
  if (slideshow_preset == enum_custom):
    combobox_dfslides.setValue("Custom")
    enableEditing()
    slideshow_list.displayName = newname
  else:
    combobox_dfslides.setValue(newname)
    enableEditing(false)

proc getPremadeFrame(index : int) : string =
  # for the premade special cases; and testing purposes
  var num = intToStr(index+1)
  case slideshow_name
    of "Bad Apple":
      while (len(num) < 4):
        num = "0" & num
      return RESOURCE_DIRECTORY & "sample_slideshow\\bad_apple\\bap" & num & ".png"
    of "Rickroll":
      while (len(num) < 4):
        num = "0" & num
      return RESOURCE_DIRECTORY & "sample_slideshow\\rickroll\\ric" & num & ".jpg"

proc changePreview(mode : switchmode = mode_set, index : int) =
  var indx : int
  case mode
    of mode_left: # go left
      if (index == 0): indx = slideshow_index - 1
      else: indx = 0
    of mode_set: # set to this val
      indx = index
    of mode_right: # go right
      if (index == 0): indx = slideshow_index + 1
      else: indx = slideshow_len
  indx = clamp(indx, 0, slideshow_len)
  slideshow_index = indx

  # set is triggered by slider, so this avoids infinite recursion
  if (mode != mode_set): preview_slider.setValue(indx)
  
  # disable/enable buttons
  # Left buttons
  if (slideshow_index == 0):
    button_lm.disable(); button_l.disable(); button_swp.disable()
  else:
    button_lm.enable(); button_l.enable()
    if (slideshow_preset == enum_custom): button_swp.enable()
  # Right buttons
  if (slideshow_index == slideshow_len):
    button_rm.disable(); button_r.disable(); button_swn.disable()
  else:
    button_rm.enable(); button_r.enable()
    if (slideshow_preset == enum_custom): button_swn.enable()

  # variable for the new preview images
  var newimg : string
  var newimgl : string
  var newimgr : string

  if (slideshow_preset != enum_custom):
    newimg = get_premade_frame(indx)
    newimgl = get_premade_frame(indx-1)
    newimgr = get_premade_frame(indx+1)
  elif (slideshow_list.length > 0):
    let lenn : float = wp_get_frame(slideshow_list, indx).duration
    label_duration.setLabel("Image Duration: (" & $lenn & " seconds)"); textctrl_duration.setValue($lenn); textctrl_duration.enable()

    newimg = wp_get_frame_file(slideshow_list, indx)
    newimgl = wp_get_frame_file(slideshow_list, indx-1)
    newimgr = wp_get_frame_file(slideshow_list, indx+1)

  # update preview
  if (slideshow_preset == enum_custom and slideshow_list.length == 0): framenumber.setTitle("Frame 0/0")
  else: framenumber.setTitle("Frame " & intToStr(indx+1) & "/" & intToStr(slideshow_len+1))
  #updating the main preview
  if (fileExists(newimg)):
    preview.getBitmap().delete()
    preview.setBitmap(Bitmap(newimg))
  else:
    newimg = RESOURCE_DIRECTORY & "sample_slideshow\\not_found.png"
    if (fileExists(newimg)):
        preview.getBitmap().delete()
        preview.setBitmap(Bitmap(newimg))
  # updating the secondary sub-previews
  if (fileExists(newimgl)):
    previewl.show()
    previewl.getBitmap().delete()
    previewl.setBitmap(Bitmap(newimgl))
  else: previewl.hide()
  if (fileExists(newimgr)):
    previewr.show()
    previewr.getBitmap().delete()
    previewr.setBitmap(Bitmap(newimgr))
  else: previewr.hide()

proc setSlideshowLength(len : int, new_indx : int = 0) =
  var new_indx_clamped = new_indx
  if (new_indx_clamped > len): new_indx_clamped = len
  slideshow_len = len
  preview_slider.setRange(0..slideshow_len)
  preview_slider.setValue(new_indx_clamped)
  slideshow_index = new_indx_clamped
  changePreview(index=new_indx_clamped)
  # if custom and blank, replace and delete should be disabled
  if (slideshow_preset == enum_custom and slideshow_list.length == 0):
    button_replace.disable()
    button_del.disable()

proc setFrameDuration(newduration : string) =
  # if its a preset you cannot adjust duration
  if (slideshow_preset == enum_preset): return
  try:
    var my_duration = parseFloat(newduration)
    textctrl_duration.setValue($my_duration)
    label_duration.setLabel("Image Duration: (" & $my_duration & " seconds)")
    wp_change_duration(slideshow_list, my_duration, slideshow_index)
  except:
    # if fails, reset to what it was before
    textctrl_duration.setValue($wp_get_frame(slideshow_list, slideshow_index).duration)

proc loadPreset(preset : string) =
  case preset
    of "Custom":
      slideshow_preset = enum_custom
      textctrl_name.enable()
      # make default custom slideshow
      changeName(slideshow_list.displayName)
      var clamped_len = slideshow_list.length-1
      if (clamped_len < 0): clamped_len = 0
      setSlideshowLength(clamped_len)

      # set durations
      changePreview(index=0)
      if (slideshow_list.length == 0):
        label_duration.setLabel("Image Duration: (0.0 seconds)"); textctrl_duration.setValue("0.0"); textctrl_duration.disable()
      else:
        let lenn : float = slideshow_list.files[slideshow_index].duration
        label_duration.setLabel("Image Duration: (" & $lenn & " seconds)"); textctrl_duration.setValue($lenn); textctrl_duration.enable()
    of "Rickroll":
      slideshow_preset = enum_preset
      textctrl_name.disable()
      changeName("Rickroll")
      setSlideshowLength(318)
      label_duration.setLabel("Image Duration: (0.664 seconds)"); textctrl_duration.setValue("0.664"); textctrl_duration.disable()
    of "Bad Apple":
      slideshow_preset = enum_preset
      textctrl_name.disable()
      changeName("Bad Apple")
      setSlideshowLength(326)
      label_duration.setLabel("Image Duration: (0.664 seconds)"); textctrl_duration.setValue("0.664"); textctrl_duration.disable()

proc loadImage(replace : bool = false) =
  var fd : wFileDialog
  if (replace): fd = FileDialog(style=wFdOpen, wildcard="All Picture Files|*.bmp;*.dib;*jpg;*jpeg;*jpe;*.jfif;*.gif;*.tif;*.tiff;*.png;*.ico;*.heic;*.hif;*.avif;*.webp")
  else: fd = FileDialog(style=wFdOpen or wFdMultiple or wFdFileMustExist, wildcard="All Picture Files|*.bmp;*.dib;*jpg;*jpeg;*jpe;*.jfif;*.gif;*.tif;*.tiff;*.png;*.ico;*.heic;*.hif;*.avif;*.webp")

  echo fd.display()

  let imgs = fd.getPaths()

  # replace logic
  if (replace):
    if (not fileExists(imgs[0])): return
    wp_replace_frame(slideshow_list, imgs[0], slideshow_index)

    # update ui and exit
    changePreview(index=slideshow_index)
    return

  # append logic
  for img in imgs:
    # skip if no file
    if (not fileExists(img)): continue

    # new frame
    var newframe : WallpaperFrame = default(WallpaperFrame)
    newframe.fileName = img
    newframe.duration = 10.0

    # add image to next index
    if (slideshow_list.length == 0):
      # adding first frame (a special case)
      wp_add_frame(slideshow_list, newframe, 0)
      enableEditing()
    else:
      wp_add_frame(slideshow_list, newframe, slideshow_index + 1)
      # update length and position
      slideshow_len = slideshow_list.length - 1
      slideshow_index += 1
  
  # update ui
  setSlideshowLength(slideshow_len, slideshow_index)
  changePreview(index=slideshow_index)

proc swapImage(next : bool = false) =
  var index = slideshow_index
  if (not next): index -= 1
  wp_swap_frame_with_next(slideshow_list, index)
  changePreview(index=slideshow_index)

proc deleteImage() =
  discard wp_delete_frame(slideshow_list, slideshow_index)
  var clamped_len = slideshow_list.length-1
  if (clamped_len < 0): clamped_len = 0
  setSlideshowLength(clamped_len, slideshow_index)
  changePreview(index=slideshow_index)

  # emergency if go down to zero
  if (slideshow_list.length == 0):
    label_duration.setLabel("Image Duration: (0.0 seconds)"); textctrl_duration.setValue("0.0"); textctrl_duration.disable()

# Saving/Loading Logic
proc loadFile() =
  var fd = FileDialog(style=wFdOpen or wFdFileMustExist, wildcard="Nimfinite Wallpaper template (*.nimwal)|*.nimwal")
  echo fd.display()

  let files = fd.getPaths()
  if len(files) == 0: return
  let file = files[0]

  let contents = readFile(file).split('\n')
  if len(contents) == 0: return
  
  # make sure its set to custom
  loadPreset("Custom")

  # wipe it clean
  while (slideshow_list.length > 0):
    discard wp_delete_frame(slideshow_list, 0)

  # alright time to load
  changeName(contents[0])
  
  for line in contents:
    if '\0' in line:
      let linedata = line.split('\0')
      if (len(linedata) != 2): continue

      # new frame
      var newframe : WallpaperFrame = default(WallpaperFrame)
      newframe.fileName = linedata[0]
      newframe.duration = parseFloat(linedata[1])

      # add image to next index
      if (slideshow_list.length == 0):
        # adding first frame (a special case)
        wp_add_frame(slideshow_list, newframe, 0)
        enableEditing()
      else:
        wp_add_frame(slideshow_list, newframe, slideshow_index + 1)
        # update length and position
        slideshow_len = slideshow_list.length - 1
        slideshow_index += 1

  # now refresh the gui
  changePreview(index=0)
  setSlideshowLength(slideshow_len)

proc saveFile() =
  var fd = FileDialog(style=wFdSave, wildcard="Nimfinite Wallpaper template (*.nimwal)|*.nimwal")
  echo fd.display()

  let files = fd.getPaths()
  if len(files) == 0: return
  var path = files[0]

  # make sure it ends in .nimwal
  if '.' in path:
    path = path.split('.')[0]
  path &= ".nimwal"

  # build up string of save data
  var content : string = slideshow_list.displayName & '\n'
  for cursor in 0 .. slideshow_len:
    content &= wp_get_frame(slideshow_list, cursor).fileName & '\0'
    content &= $wp_get_frame(slideshow_list, cursor).duration & '\n'

  writeFile(path, content)


# slideshow logic
var lastTime: Time = getTime()
var currentTime: Time
var negativeCatchupTime: int = 0

proc calculatedSleep(sleepLen_ms : int): void =
    # calculate delay offset from delay of wallpaper change
    currentTime = getTime()
    let offsetSleeplen_ms : int = sleepLen_ms - int((currentTime - lastTime).inMilliseconds) + negativeCatchupTime
    # sleep using offset
    if (offsetSleeplen_ms > 0):
        sleep(offsetSleeplen_ms)
    echo "\nSLEEPING FOR: "
    echo offsetSleeplen_ms
    # if this one frame took way too long, try to catch up if possible
    if (offsetSleeplen_ms < 0):
        negativeCatchupTime = min(offsetSleeplen_ms, negativeCatchupTime)
    else:
        negativeCatchupTime = 0
    # reset lastTime for next time
    lastTime = getTime()

proc slideshow() =
  # reset timer compensator
  lastTime = getTime()

  if (slideshow_preset == enum_custom):
    for cursor in 0 .. slideshow_len:
      let widestr: LPCWSTR = newWideCString(wp_get_frame(slideshow_list, cursor).fileName)
      let duration = int(wp_get_frame(slideshow_list, cursor).duration * 1000)

      if (negativeCatchupTime * -1 > duration):
        # skip frames if took too long to set
        negativeCatchupTime += duration
      else:
        discard SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, widestr, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE)
        calculatedSleep(duration)
  else:
    # RESTATE THE CURRENT DIRECTORY BECAUSE NIM WONT LET ME GIVE STRINGS TO THE SECONDARY THREAD
    var folder = RESOURCE_DIRECTORY
    case slideshow_name
    of "Bad Apple":
      folder &= "sample_slideshow\\bad_apple"
    of "Rickroll":
      folder &= "sample_slideshow\\rickroll"

    let min_time_ms = 664

    #while (playing):
    for kind, path in walkDir(folder):
      # widen the string because Windows only reads wide strings
      let widestr: LPCWSTR = newWideCString(path)
  
      if (kind == pcFile):
        if (negativeCatchupTime * -1 > min_time_ms):
          # skip frames if took too long to set
          negativeCatchupTime += min_time_ms
        else:
          discard SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, widestr, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE)
          calculatedSleep(min_time_ms)
      # break out if stopping
      #if (not playing): break



proc togglePlay() =
  slideshow()
  #playing = not playing
  #if (playing):
    #slideshow()
    #createThread(thr[], slideshow)
    #button_play.setLabel("Stop Slideshow")
    # disable playing and loading
    #button_ldslides.disable()
    #combobox_dfslides.disable()
    # disable editing too
    #enableEditing(false)
  #else:
    #button_play.disable()
    #button_play.setLabel(". . . Stopping . . .")
    #joinThreads(thr[])
    #button_play.setLabel("Play Slideshow")
    #sleep(1) # for some reason without this, it glitches
    
    # enable playing and loading again
    #button_play.enable()
    #button_ldslides.enable()
    #combobox_dfslides.enable()
    # enable editing too
    #enableEditing(slideshow_preset == enum_custom)



# 'Slideshow Loading' Panel
button_ldslides.wEvent_Button do (): loadFile()
button_svslides.wEvent_Button do (): saveFile()
combobox_dfslides.wEvent_ComboBox do (): loadPreset(combobox_dfslides.getValue())
textctrl_name.wEvent_TextEnter do (): changeName(textctrl_name.getValue())

# 'Edit Slideshow' Panel
preview_slider.wEvent_Slider do (): changePreview(index = preview_slider.getValue())
textctrl_duration.wEvent_TextEnter do (): setFrameDuration(textctrl_duration.getValue())
button_l.wEvent_Button do (): changePreview(mode_left, 0)
button_r.wEvent_Button do (): changePreview(mode_right, 0)
button_lm.wEvent_Button do (): changePreview(mode_left, 1)
button_rm.wEvent_Button do (): changePreview(mode_right, 1)

button_insert.wEvent_Button do (): loadImage(false)
button_replace.wEvent_Button do (): loadImage(true)
button_swn.wEvent_Button do (): swapImage(true)
button_swp.wEvent_Button do (): swapImage(false)
button_del.wEvent_Button do (): deleteImage()

# 'Playback' panel
button_play.wEvent_Button do (): togglePlay()

proc layout() =
  panel.autolayout """
    spacing: 10
    H:|-[staticbox1,staticbox2,staticbox3,staticbox4]-|
    V:|-[staticbox1(128)]-[staticbox2(preview.width*0.5625+136)]-(-38)-[staticbox3(136)]-[staticbox4(64)]

    outer: staticbox1
    H:|-5-[button_ldslides(30%),label_ld,combobox_dfslides(30%),label_ps]~[label_name,label_ename,textctrl_name(30%)]~[button_svslides(30%)]-5-|
    V:|-5-[label_ps,button_svslides]-(-8)-[combobox_dfslides,label_name]-[label_ld,label_ename]-(-8)-[button_ldslides,textctrl_name]

    outer: staticbox2
    H:|~[button_lm(10%)][button_l(10%),previewl(10%)][framenumber,preview(40%),preview_slider,label_duration,textctrl_duration][button_r(10%),previewr(10%)][button_rm(10%)]~|
    V:|-5-[framenumber(16)]-0-[preview(preview.width*0.5625)]-(preview.height*-0.6)-[previewl(previewl.width*0.5625),previewr(previewl.width*0.5625)]-[button_lm,button_l,button_r,button_rm]-(preview.height*0.35-36)-[preview_slider(32)]-[label_duration]-(-8)-[textctrl_duration]

    outer: staticbox3
    H:|-5-[button_replace(45%),button_swp(45%)]-[button_insert(45%),button_swn(45%),button_del(45%)]-5-|
    V:|-5-[button_replace,button_insert]-[button_swp,button_swn]-[button_del]

    outer: staticbox4
    H:|~[button_play(90%)]~|
    V:|-5-[button_play]-5-|
  """


# set up
changePreview(index=0)
loadPreset("Bad Apple")

panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()


