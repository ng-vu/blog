# AppleScript

## Snippets

### Click a menu bar icon

```ap
tell application "System Events" to tell process "foo"
    click menu bar item 1 of menu bar 2
end tell
```

### Get menu bar items of menu bar icon

**Reference**: https://apple.stackexchange.com/questions/311465/how-can-i-get-access-to-menu-bar-item-in-bartender-3-using-applescript

```applescript
tell application "System Events"
	tell process "GoTiengViet"
		tell menu bar item 1 of menu bar 2
			click
			get menu items of menu 1
		end tell
	end tell
end tell
```

There is a delay of 5 seconds. We have to use this hack ([stackoverflow](https://stackoverflow.com/questions/21270264/speed-up-applescript-ui-scripting?answertab=active#tab-top)).

```applescript
tell application "System Events"
	keystroke "z" using option down
	tell process "GoTiengViet"
		ignoring application responses
			click menu bar item 1 of menu bar 2
		end ignoring
	end tell
end tell

do shell script "killall System\\ Events"
delay 0.1

tell application "System Events"
	tell process "GoTiengViet"
		tell menu bar item 1 of menu bar 2
			set checked to get value of attribute "AXMenuItemMarkChar" of menu item "Gõ tiếng Việt" of menu 1
		end tell
	end tell
	key code 53
	if checked is "✓" then
		return "V"
	else
		return "E"
	end if
end tell
```

This will return `✓` if the item is checked or `missing value`.

### Send keystroke

```applescript
tell application "System Events"
	keystroke "v" using {command down, option down, control down, shift down}
end tell
```

