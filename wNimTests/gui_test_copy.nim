import wNim/[wApp, wFrame, wPanel, wStatusBar, wMenu,
  wBitmap, wStaticBox, wStaticLine, wStaticBitmap, wStaticText,
  wButton, wRadioButton, wCheckBox, wComboBox, wCheckComboBox, wListBox,
  wNoteBook, wTextCtrl, wSpinCtrl, wHotkeyCtrl, wSlider, wGauge,
  wDatePickerCtrl, wTimePickerCtrl, wFileDialog, wImage]
import std/os, strutils

# enums because enums
type
  switchmode = enum
    mode_left, mode_set, mode_right
  preset = enum
    enum_preset
    enum_custom

# consts
let RESOURCE_DIRECTORY = getCurrentDir() & "\\..\\src\\"


# custom vars to adjust throughout development to test
var slideshow_len = 326
var slideshow_preset = enum_preset
var slideshow_name = "Bad Apple"


# Window
let app = App(wSystemDpiAware)
let frame = Frame(title="Nimfinite Wallpapers", style=wDefaultFrameStyle or wModalFrame)
frame.dpiAutoScale:
  frame.size = (640, 610)
  frame.minSize = (500, 580)

# Panels
let statusBar = StatusBar(frame)
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

let preview_slider = Slider(panel, value=0, range=0..slideshow_len, style=wSlAutoTicks)
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
  var fd = FileDialog(style=wFdOpen or wFdMultiple or wFdFileMustExist)
  echo fd.display()

  let imgs = fd.getPaths()
  for img in imgs:
    echo img
    #staticbitmap.setBitmap(bitmap=Bitmap(img))
    #frame.refresh(eraseBackground=true)

proc saveFile() =
  var fd = FileDialog(style=wFdSave)
  echo fd.display()

proc changeName(newname : string) =
  slideshow_name = newname
  label_name.setLabel(newname)
  textctrl_name.setValue(newname)
  if (slideshow_preset == enum_custom):
    button_svslides.enable()
    combobox_dfslides.setValue("Custom")
    textctrl_name.enable()
    button_replace.enable()
    button_insert.enable()
    button_swn.enable()
    button_swp.enable()
    button_del.enable()
  else:
    combobox_dfslides.setValue(newname)
    button_svslides.disable()
    textctrl_name.disable()
    button_replace.disable()
    button_insert.disable()
    button_swn.disable()
    button_swp.disable()
    button_del.disable()

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
  
  # variable for the new preview images
  var newimg : string
  var newimgl : string
  var newimgr : string

  if (slideshow_preset != enum_custom):
    newimg = get_premade_frame(indx)
    newimgl = get_premade_frame(indx-1)
    newimgr = get_premade_frame(indx+1)

  # update preview
  framenumber.setTitle("Frame " & intToStr(indx) & "/" & intToStr(slideshow_len))
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

proc loadPreset(preset : string) =
  case preset
    of "Custom":
      slideshow_preset = enum_custom
      textctrl_name.enable()
      # TODO: make default custom slideshow
      slideshow_len = 0
    of "Rickroll":
      slideshow_preset = enum_preset
      textctrl_name.disable()
      changeName("Rickroll")
      slideshow_len = 318
    of "Bad Apple":
      slideshow_preset = enum_preset
      textctrl_name.disable()
      changeName("Bad Apple")
      slideshow_len = 326
  changePreview(index=0)


proc togglePlay() =
  playing = not playing
  if (playing):
    button_play.setLabel("Stop Slideshow")
  else:
    button_play.setLabel("Play Slideshow")


button_ldslides.wEvent_Button do (): loadFile()
button_svslides.wEvent_Button do (): saveFile()
combobox_dfslides.wEvent_ComboBox do (): loadPreset(combobox_dfslides.getValue())

preview_slider.wEvent_Slider do (): changePreview(index = preview_slider.getValue())
button_l.wEvent_Button do (): changePreview(mode_left, 0)
button_r.wEvent_Button do (): changePreview(mode_right, 0)
button_lm.wEvent_Button do (): changePreview(mode_left, 1)
button_rm.wEvent_Button do (): changePreview(mode_right, 1)
button_play.wEvent_Button do (): togglePlay()

proc layout() =
  panel.autolayout """
    spacing: 10
    H:|-[staticbox1,staticbox2,staticbox3,staticbox4]-|
    V:|-[staticbox1(128)]-[staticbox2]-(-38)-[staticbox3(128)]-[staticbox4(64)]

    outer: staticbox1
    H:|-5-[button_ldslides(30%),label_ld,combobox_dfslides(30%),label_ps]~[label_name,label_ename,textctrl_name(30%)]~[button_svslides(30%)]-5-|
    V:|-5-[label_ps,button_svslides]-(-8)-[combobox_dfslides,label_name]-[label_ld,label_ename]-(-8)-[button_ldslides,textctrl_name]
    

    outer: staticbox2
    H:|~[button_lm(10%)][button_l(10%),previewl(10%)][framenumber,preview(40%),preview_slider][button_r(10%),previewr(10%)][button_rm(10%)]~|
    V:|-5-[framenumber(16)]-0-[preview(preview.width*0.5625)]-(preview.height*-0.6)-[previewl(previewl.width*0.5625),previewr(previewl.width*0.5625)]-[button_lm,button_l,button_r,button_rm]-(preview.height*0.35-32)-[preview_slider(32)]-5-|

    outer: staticbox3
    H:|-5-[button_replace(45%),button_swp(45%)]-[button_insert(45%),button_swn(45%),button_del(45%)]-5-|
    V:|-5-[button_replace,button_insert]-[button_swp,button_swn]-[button_del]

    outer: staticbox4
    H:|~[button_play(90%)]~|
    V:|-5-[button_play]-5-|
  """


# set up
changeName("Bad Apple")
changePreview(index=0)


panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()


