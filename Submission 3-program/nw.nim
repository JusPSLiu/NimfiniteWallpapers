# Jus Liu        801276699
# Ryan O'Connor  801296594
# Mason Scarbro  801371337
# Ariel Vera     801295826
# Daniel Willett 801432278

import winim
import std/[os, sequtils, random, streams, strutils, paths]

const configFile = "wallpaperpath.txt"

proc readPaths(): seq[string];
proc writePaths(paths: seq[string]): bool;
proc listAllPaths(paths: seq[string]): void;
proc setWallpaper(fileName: string): bool;

var allPaths = readPaths()

let exeName = paramStr(0)

# nw
if paramCount() == 0:
  listAllPaths(allPaths)
  echo " (Run '", exeName, " help' for more information)"
  quit(1)

let command = paramStr(1).toLowerAscii()

case command

# nw help
of "help":
  echo "Usage:"
  echo "  ", exeName, " add \"C:/some/path\" -- Add a wallpaper."
  echo "  ", exeName, " remove <#> -- Remove a wallpaper."
  echo "  ", exeName, " set <#> -- Set your wallpaper to that number."
  echo "  ", exeName, " random -- Set your wallpaper to a random one."
  echo "  ", exeName, " help -- This menu."

# nw random
of "random":
  if allPaths.len == 0:
    echo "No wallpapers."
    quit(1)
  
  randomize()
  var randomValue: float = rand(0.9999)

  var randomWallpaper = int(randomValue * float(allPaths.len))
  
  var path: string = allPaths[randomWallpaper]
  if setWallpaper(path):
    echo "Wallpaper set to \"", path, "\"."
  else:
    quit(1)

# nw set 1
of "set":
  if paramCount() < 2:
    echo "Error: Missing wallpaper number."
    quit(1)

  let number: int = parseInt(paramStr(2)) - 1
  if number < 0 or number >= allPaths.len:
    echo "Number out of range."
    quit(1)
  
  var path: string = allPaths[number]
  if setWallpaper(path):
    echo "Wallpaper set to \"", path, "\"."
  else:
    quit(1)
  
# nw add ./Wallpaper.png
of "add":
  
  if paramCount() < 2:
    echo "Error: Missing path argument."
    quit(1)

  let path = paramStr(2)

  if allPaths.contains(path):
    echo "Wallpaper \"", path, "\" is already added."
    quit(1)

  try:
    if fileExists(path):
      allPaths.add(path)
      if writePaths(allPaths):
        echo "Added wallpaper at \"", path, "\"."
      else:
        quit(1)
    else:
      echo "File not found: \"", path, "\"."
      quit(1)

  except IOError:
    echo "Unable to access that file."
    quit(1)

# nw remove 1
of "remove":
  
  if paramCount() < 2:
    echo "Error: Missing wallpaper number."
    quit(1)

  let number: int = parseInt(paramStr(2)) - 1
  if number < 0 or number >= allPaths.len:
    echo "Number out of range."
    quit(1)
  
  var path: string = allPaths[number]

  allPaths.delete(number..number)
  if writePaths(allPaths):
    echo "Removed wallpaper at \"", path, "\"."
  else:
    quit(1)

else:
  echo "Unknown command: ", command
  echo "  '", exeName, " help' for more info."

# Sets the wallpaper using the Win32 API: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow
proc setWallpaper(fileName: string): bool =
    var absFileName = absolutePath(fileName)
    let widestr: LPCWSTR = newWideCString(absFileName)
    return SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, widestr, SPIF_SENDCHANGE)

# Reads the path configuration file.
proc readPaths(): seq[string] =
  var fileContents: string
  try:
    fileContents = readFile(configFile)
  except IOError:
    fileContents = ""
  
  var outPaths: seq[string] = newSeq[string]()
  
  for path in splitLines(fileContents, false):

    if path.len <= 0:
      continue

    if fileExists(path):
      outPaths.add(path)
    else:
      echo "File removed because it no longer exists: ", path 
      

  return outPaths

# Writes the path configuration file.
proc writePaths(paths: seq[string]): bool =
  try:
    var stream = newFileStream(configFile, fmWrite)
    if not isNil(stream):
      for path in paths:
        stream.writeLine(path)
      stream.close()
      return true
  except IOError:
    discard

  echo "Failed to write to file."
  return false

# Prints all wallpaper paths.
proc listAllPaths(paths: seq[string]): void =
  if paths.len == 0:
    echo "No wallpapers added yet."
    return
  var index = 0
  for path in paths:
    index += 1
    echo index, ") ", path