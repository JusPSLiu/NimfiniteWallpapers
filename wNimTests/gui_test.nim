
#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                Copyright (c) Chen Kai-Hung, Ward
#
#====================================================================

import wNim/[wApp, wFrame, wPanel, wStatusBar, wMenu,
  wBitmap, wPen, wBrush, wPaintDC,
  wStaticBox, wStaticLine, wStaticBitmap, wStaticText,
  wButton, wRadioButton, wCheckBox, wComboBox, wCheckComboBox, wListBox,
  wNoteBook, wTextCtrl, wSpinCtrl, wHotkeyCtrl, wSlider, wGauge,
  wDatePickerCtrl, wTimePickerCtrl, wFileDialog, wImage]
import std/os

let app = App(wSystemDpiAware)
let frame = Frame(title="wNim Demo", style=wDefaultFrameStyle or wModalFrame)
frame.dpiAutoScale:
  frame.size = (640, 530)
  frame.minSize = (500, 450)

let statusBar = StatusBar(frame)
let panel = Panel(frame)
let staticbox1 = StaticBox(panel, label="Basic Controls")
let staticbox2 = StaticBox(panel, label="Numbers Controls")
let staticbox3 = StaticBox(panel, label="Lists Controls")

let button = Button(panel, label="Open Image File")
let checkbox = CheckBox(panel, label="CheckBox")
let textctrl = TextCtrl(panel, value="TextCtrl", style=wBorderSunken)
let statictext = StaticText(panel, label="StaticText")
let staticline = StaticLine(panel)

let hotkeyctrl = HotKeyCtrl(panel, value="Ctrl + D", style=wBorderSunken)
let datepickerctrl = DatePickerCtrl(panel)
let timepickerctrl = TimePickerCtrl(panel)

let spinctrl = SpinCtrl(panel, value=50, style=wSpArrowKeys)
let slider = Slider(panel, value=50)
let gauge = Gauge(panel, value=50)

let combobox = ComboBox(panel, value="Combobox Item1",
  choices=["Combobox Item1", "Combobox Item2", "Combobox Item3"],
  style=wCbReadOnly)

let checkcombobox = CheckComboBox(panel,
  choices=["CheckCombobox Item1", "CheckCombobox Item2", "CheckCombobox Item3"],
  style=wCcEndEllipsis)
checkcombobox.select(0)

let editable = ComboBox(panel, value="Editable Item1",
  choices=["Editable Item1", "Editable Item2", "Editable Item3"],
  style=wCbDropDown)

let radiobutton1 = RadioButton(panel, label="Radio Button 1")
let radiobutton2 = RadioButton(panel, label="Radio Button 2")
let radiobutton3 = RadioButton(panel, label="Radio Button 3")

let notebook = NoteBook(panel)
notebook.addPage("Page1")
notebook.addPage("Page2")
notebook.addPage("Page3")

let logo = getCurrentDir() & "\\..\\src\\sample_slideshow\\bad_apple\\bap0022.png"
let staticbitmap = StaticBitmap(notebook.page(0), bitmap=Bitmap(logo), style=wSbFit)
staticbitmap.backgroundColor = -1

notebook.page(1).wEvent_Paint do (event: wEvent):
  let size = event.window.clientSize
  let factorX = size.width / 460
  let factorY = size.height / 120

  var dc = PaintDC(event.window)
  dc.brush = Brush(color=0xD9AA85)
  dc.pen = wTransparentPen
  dc.scale = (factorX, factorY)
  dc.drawEllipse(15, 35, 90, 50)
  dc.drawRoundedRectangle(130, 35, 90, 50, 10)
  dc.drawArc(240, 45, 340, 45, 290, 30)
  dc.drawPolygon([(355, 65), (405, 95), (405, 65), (445, 35), (365, 25)])

let listbox = ListBox(notebook.page(2), style=wLbNoSel or wBorderSimple or wLbNeededScroll)

listbox.wEvent_ContextMenu do ():
  let menu = Menu()
  menu.append(wIdClear, "&Clear")
  listbox.popupMenu(menu)

frame.wIdClear do ():
  listbox.clear()

proc add(self: wListBox, text: string) =
  self.ensureVisible(self.append(text))

proc openDialog() =
  var fd = FileDialog(style=wFdOpen or wFdMultiple or wFdFileMustExist)
  echo fd.display()

  let imgs = fd.getPaths()
  for img in imgs:
    echo img
    staticbitmap.setBitmap(bitmap=Bitmap(img))
    frame.refresh(eraseBackground=true)

button.wEvent_Button do (): openDialog()
checkbox.wEvent_CheckBox do (): listbox.add "checkbox.wEvent_CheckBox"
textctrl.wEvent_Text do (): listbox.add "textctrl.wEvent_Text"
statictext.wEvent_MouseEnter do (): listbox.add "statictext.wEvent_MouseEnter"
statictext.wEvent_MouseLeave do (): listbox.add "statictext.wEvent_MouseLeave"
hotkeyctrl.wEvent_HotkeyChanged do (): listbox.add "hotkeyctrl.wEvent_HotkeyChanged"
datepickerctrl.wEvent_DateChanged  do (): listbox.add "datepickerctrl.wEvent_DateChanged"
timepickerctrl.wEvent_TimeChanged  do (): listbox.add "timepickerctrl.wEvent_TimeChanged"
spinctrl.wEvent_Spin do (): listbox.add "spinctrl.wEvent_Spin"
slider.wEvent_Slider do (): listbox.add "slider.wEvent_Slider"
combobox.wEvent_ComboBox do (): listbox.add "combobox.wEvent_ComboBox"
checkcombobox.wEvent_CheckComboBox do (): listbox.add "checkcombobox.wEvent_CheckComboBox"
editable.wEvent_ComboBox do (): listbox.add "editable.wEvent_ComboBox"
editable.editControl.wEvent_Text do (): listbox.add "editable.editControl.wEvent_Text"
radiobutton1.wEvent_RadioButton do (): listbox.add "radiobutton1.wEvent_RadioButton"
radiobutton2.wEvent_RadioButton do (): listbox.add "radiobutton2.wEvent_RadioButton"
radiobutton3.wEvent_RadioButton do (): listbox.add "radiobutton3.wEvent_RadioButton"
notebook.wEvent_NoteBookPageChanged do (): listbox.add "notebook.wEvent_NoteBookPageChanged"
staticbitmap.wEvent_CommandLeftClick do (): listbox.add "staticbitmap.wEvent_CommandLeftClick"

proc layout() =
  panel.autolayout """
    spacing: 10
    H:|-[staticbox1,notebook]-[staticbox2..3,notebook]-|
    V:|-[staticbox1]-[notebook]-|
    V:|-[staticbox2]-[staticbox3]-[notebook]-|

    outer: staticbox1
    V:|-5-{stack1:[button]-[checkbox]-[textctrl]-[statictext]}-[staticline]-
      {stack2:[hotkeyctrl]-[datepickerctrl]-[timepickerctrl]}
    H:|-5-[stack1..2,staticline]-5-|

    outer: staticbox2
    V:|-5-{stack3:[spinctrl]-[slider]-[gauge]}-5-|
    H:|-5-[stack3]-5-|

    outer: staticbox3
    V:|-5-{stack4:[combobox]-[checkcombobox]-[editable]-
      [radiobutton1][radiobutton2][radiobutton3]}-5-|
    H:|-5-[stack4]-5-|

    V:[stack1..4(25)]
  """

  notebook.autolayout """
    HV:|[staticbitmap,listbox]|
  """

panel.wEvent_Size do ():
  layout()

layout()
frame.center()
frame.show()
app.mainLoop()