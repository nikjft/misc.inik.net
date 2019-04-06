on run
	tell application "Finder"
		get quoted form of POSIX path of my getCurrentFolder()
		do shell script "chdir " & result & "; python -m SimpleHTTPServer 8080"
	end tell
end run

on termScriptInNewTab(cmd)
	tell application "Terminal"
		activate
		set termWins to count of windows
		set frontWin to 0
		repeat with i from 1 to (count of windows)
			try
				set tabCount to count of tabs of window i
				set frontWin to i
				exit repeat
			end try
		end repeat
		if frontWin is 0 then
			do script cmd
		else
			set frontmost of window frontWin to true
			tell application "System Events" to tell (first application process whose name is "Terminal") to keystroke "t" using {command down}
			set xi to 0
			repeat until (count of tabs of window 1) is (tabCount + 1)
				set xi to xi + 1
				if xi ² 4 then -- don't wait more than one second
					
					delay 0.25
				else
					set xi to -1
					exit repeat
				end if
			end repeat
			
			if xi is not -1 then
				do script cmd in (last tab of window 1)
			else
				do script cmd
			end if
			
		end if
		
	end tell
end termScriptInNewTab

on getCurrentFolder()
	tell application "Finder"
		set theFolder to (path to desktop folder as alias)
		repeat with i from 0 to (count of windows)
			try
				get folder of window i
				set theFolder to result
				exit repeat
			end try
		end repeat
		return theFolder as alias
	end tell
end getCurrentFolder
