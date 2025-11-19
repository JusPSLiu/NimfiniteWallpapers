import std/[os, strutils]

# simple save/load procs
proc saveText(path: string, content: string) =
  writeFile(path, content)

proc loadText(path: string): string =
  return readFile(path)

# test paths
let testPath = "C:\\Users\\Admin\\Desktop\\NimfiniteWallpapers\\wNimTests\\test.txt"

# save a test file
saveText(testPath, "Hello Nim!\nThis is a test.")

echo "Saved test file at: ", testPath

# read the test file back
let text = loadText(testPath)
echo "--- Loaded file contents ---"
echo text