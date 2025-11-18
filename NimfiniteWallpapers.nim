import wNim/[wApp, wFrame, wPanel, wBitmap, wStaticBox, wStaticBitmap, wStaticText,
  wButton, wComboBox,
  wTextCtrl, wSlider,
  wFileDialog, wImage]
import std/os, strutils  # for strings and os
import winim
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


# custom vars to adjust throughout development to test
var slideshow_len = 326
var slideshow_preset = enum_preset
var slideshow_name = "Bad Apple"

var thr = new Thread[void]

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

proc loadFile() =
  var fd = FileDialog(style=wFdOpen or wFdMultiple or wFdFileMustExist, wildcard="Text documents (*.txt)|*.txt")
  echo fd.display()

  let imgs = fd.getPaths()
  for img in imgs:
    echo img
    #staticbitmap.setBitmap(bitmap=Bitmap(img))
    #frame.refresh(eraseBackground=true)

proc saveFile() =
  var fd = FileDialog(style=wFdSave, wildcard="Text documents (*.txt)|*.txt")
  echo fd.display()

proc enableEditing(enable : bool = true) =
  if (enable):
    button_svslides.enable()
    textctrl_name.enable()
    button_replace.enable()
    button_insert.enable()
    button_swn.enable()
    button_swp.enable()
    button_del.enable()
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
  label_name.setLabel(newname)
  textctrl_name.setValue(newname)
  if (slideshow_preset == enum_custom):
    combobox_dfslides.setValue("Custom")
    enableEditing()
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
      if (index == 0): indx = preview_slider.getValue() - 1
      else: indx = 0
    of mode_set: # set to this val
      indx = index
    of mode_right: # go right
      if (index == 0): indx = preview_slider.getValue() + 1
      else: indx = slideshow_len
  indx = clamp(indx, 0, slideshow_len)
  if (mode != mode_set): preview_slider.setValue(indx)

  # disable/enable buttons
  # Left buttons
  if (preview_slider.getValue() == 0):
    button_lm.disable(); button_l.disable(); button_swp.disable()
  else:
    button_lm.enable(); button_l.enable()
    if (slideshow_preset == enum_custom): button_swp.enable()
  # Right buttons
  if (preview_slider.getValue() == slideshow_len):
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

  # update preview
  framenumber.setTitle("Frame " & intToStr(indx+1) & "/" & intToStr(slideshow_len+1))
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
  slideshow_len = len
  preview_slider.setRange(0..slideshow_len)
  preview_slider.setValue(new_indx)
  changePreview(index=new_indx)
  if (len == 0):
    button_replace.disable()
    button_del.disable()

proc setFrameDuration(newduration : string) =
  try:
    var my_duration = parseFloat(newduration)
    textctrl_duration.setValue($my_duration)
    label_duration.setLabel("Image Duration: (" & $my_duration & " seconds)")
  except:
    textctrl_duration.setValue("1")

proc loadPreset(preset : string) =
  case preset
    of "Custom":
      slideshow_preset = enum_custom
      textctrl_name.enable()
      # TODO: make default custom slideshow
      changeName("Custom Slideshow")
      setSlideshowLength(0)

      # set durations
      label_duration.setLabel("Image Duration: (0 seconds)")
      textctrl_duration.setValue("0.0")
      textctrl_duration.enable()
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

proc loadImage(index : int, replace : bool = false) =
  var fd : wFileDialog
  if (replace): fd = FileDialog(style=wFdOpen, wildcard="All Picture Files|*.bmp;*.dib;*jpg;*jpeg;*jpe;*.jfif;*.gif;*.tif;*.tiff;*.png;*.ico;*.heic;*.hif;*.avif;*.webp")
  else: fd = FileDialog(style=wFdOpen or wFdMultiple or wFdFileMustExist, wildcard="All Picture Files|*.bmp;*.dib;*jpg;*jpeg;*jpe;*.jfif;*.gif;*.tif;*.tiff;*.png;*.ico;*.heic;*.hif;*.avif;*.webp")

  echo fd.display()

  let imgs = fd.getPaths()
  for img in imgs:
    echo img
    #staticbitmap.setBitmap(bitmap=Bitmap(img))
    #frame.refresh(eraseBackground=true)

proc slideshow() {.thread.} =
  # var lastfile : LPCWSTR
  # 
  # let folder = RESOURCE_DIRECTORY & "\\sample_slideshow\\bad_apple"
  # 
  # for kind, path in walkDir(folder):
  #     # widen the string because Windows only reads wide strings
  #     let widestr: LPCWSTR = newWideCString(path)
  # 
  #     if (kind == pcFile):
  #         echo "File: ", path
  #         lastfile = widestr
  #         if (negativeCatchupTime * -1 > min_time_ms):
  #             # skip frames if took too long to set
  #             negativeCatchupTime += min_time_ms
  #         else:
  #             discard SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, widestr, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE)
  #             calculatedSleep(min_time_ms)

  # make sure last file is always done, and not skipped
  #discard SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, lastfile, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE)
  while (playing):
    echo "RUNNING"
    sleep(500)
    echo "STILL"
    sleep(500)

proc togglePlay() =
  playing = not playing
  if (playing):
    createThread(thr[], slideshow)
    button_play.setLabel("Stop Slideshow")
    # disable playing and loading
    button_ldslides.disable()
    combobox_dfslides.disable()
    # disable editing too
    enableEditing(false)
  else:
    button_play.disable()
    button_play.setLabel(". . . Stopping . . .")
    joinThreads(thr[])
    button_play.setLabel("Play Slideshow")
    sleep(1) # for some reason without this, it glitches
    
    # enable playing and loading again
    button_play.enable()
    button_ldslides.enable()
    combobox_dfslides.enable()
    # enable editing too
    enableEditing(slideshow_preset == enum_custom)



# 'Slideshow Loading' Panel
button_ldslides.wEvent_Button do (): loadFile()
button_svslides.wEvent_Button do (): saveFile()
combobox_dfslides.wEvent_ComboBox do (): loadPreset(combobox_dfslides.getValue())

# 'Edit Slideshow' Panel
preview_slider.wEvent_Slider do (): changePreview(index = preview_slider.getValue())
textctrl_duration.wEvent_TextEnter do (): setFrameDuration(textctrl_duration.getValue())
button_l.wEvent_Button do (): changePreview(mode_left, 0)
button_r.wEvent_Button do (): changePreview(mode_right, 0)
button_lm.wEvent_Button do (): changePreview(mode_left, 1)
button_rm.wEvent_Button do (): changePreview(mode_right, 1)

button_insert.wEvent_Button do (): loadImage(0, true)
button_replace.wEvent_Button do (): loadImage(0, true)
#button_swn.wEvent_Button do (): 
#button_swp.wEvent_Button do (): 
#button_del.wEvent_Button do (): 

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


