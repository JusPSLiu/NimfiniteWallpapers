import wNim/[wApp, wFrame, wPanel, wStatusBar, wMenu,
  wBitmap, wStaticBox, wStaticLine, wStaticBitmap, wStaticText,
  wButton, wRadioButton, wCheckBox, wComboBox, wCheckComboBox, wListBox,
  wNoteBook, wTextCtrl, wSpinCtrl, wHotkeyCtrl, wSlider, wGauge,
  wDatePickerCtrl, wTimePickerCtrl, wFileDialog, wImage]
import std/os, strutils



let slideshow_len = 326

type
  switchmode = enum
    mode_left, mode_set, mode_right


# Window
let app = App(wSystemDpiAware)
let frame = Frame(title="Nimfinite Wallpapers", style=wDefaultFrameStyle or wModalFrame)
frame.dpiAutoScale:
  frame.size = (640, 530)
  frame.minSize = (500, 450)

# Panels
let statusBar = StatusBar(frame)
let panel = Panel(frame)
let staticbox1 = StaticBox(panel, label="Slideshow Loading")
let staticbox2 = StaticBox(panel, label="Edit Slideshow")
let staticbox3 = StaticBox(panel, label="Playback")

# 'Slideshow Loading' Panel
let button_ldslides = Button(panel, label="Load Slideshow")
let button_svslides = Button(panel, label="Save Slideshow")
let combobox_dfslides = ComboBox(panel, value="Custom",
  choices=["Custom", "Rickroll", "Bad Apple"],
  style=wCbReadOnly)

# 'Edit Slideshow' Panel
let framenumber = StaticText(panel, label="Frame 1/1")
let image = getCurrentDir() & "\\..\\src\\sample_slideshow\\bad_apple\\bap0022.png"
let preview = StaticBitmap(panel, bitmap=Bitmap(image), style=wSbFit)

let preview_slider = Slider(panel, value=0, range=0..slideshow_len, style=wSlAutoTicks)
preview_slider.setTickFreq(1)
let button_l = Button(panel, label="<")
let button_r = Button(panel, label=">")
let button_lm = Button(panel, label="|<")
let button_rm = Button(panel, label=">|")

let button_replace = Button(panel, label="Replace Image")
let button_insert = Button(panel, label="Insert Image(s) (After)")


let button_play = Button(panel, label="Play Slideshow")

proc openDialog() =
  var fd = FileDialog(style=wFdOpen or wFdMultiple or wFdFileMustExist)
  echo fd.display()

  let imgs = fd.getPaths()
  for img in imgs:
    echo img
    #staticbitmap.setBitmap(bitmap=Bitmap(img))
    #frame.refresh(eraseBackground=true)



proc changePreview(mode : switchmode = mode_set, index : int) =
  var indx : int
  var num : string
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
  
  # for the premade special cases; and testing purposes
  num = intToStr(indx+1)
  while (len(num) < 4):
    num = "0" & num
  let newimg = getCurrentDir() & "\\..\\src\\sample_slideshow\\bad_apple\\bap" & num & ".png"

  # update preview
  framenumber.setTitle("Frame " & intToStr(indx) & "/" & intToStr(slideshow_len))

  if (fileExists(newimg)):
    preview.setBitmap(Bitmap(newimg))


button_ldslides.wEvent_Button do (): openDialog()
button_svslides.wEvent_Button do (): openDialog()
combobox_dfslides.wEvent_CheckComboBox do (): openDialog()

preview_slider.wEvent_Slider do (): changePreview(index = preview_slider.getValue())
button_l.wEvent_Button do (): changePreview(mode_left, 0)
button_r.wEvent_Button do (): changePreview(mode_right, 0)
button_lm.wEvent_Button do (): changePreview(mode_left, 1)
button_rm.wEvent_Button do (): changePreview(mode_right, 1)

proc layout() =
  panel.autolayout """
    spacing: 10
    H:|-[staticbox1,staticbox2, staticbox3]-|
    V:|-[staticbox1(64)]-[staticbox2]-[staticbox3(64)]-|

    outer: staticbox1
    H:|-5-[button_ldslides(25%)]~[combobox_dfslides(25%)]~[button_svslides(25%)]-5-|
    V:|-5-[button_ldslides,combobox_dfslides,button_svslides]-5-|

    outer: staticbox2
    H:|~[button_lm(10%)][button_l(10%)][framenumber,preview(40%),preview_slider][button_r(10%)][button_rm(10%)]~|
    V:|-5-[framenumber(16)]-[preview(preview.width*0.5625)]-[button_lm,button_l,preview_slider,button_r,button_rm]-5-|


    outer: staticbox3
    H:|~[button_play(90%)]~|
    V:|-5-[button_play]-5-|
  """



panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()