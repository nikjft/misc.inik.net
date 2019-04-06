tell application "Keyboard Maestro" to get selectedMacros
set theMacros to result

tell application "Keyboard Maestro Engine"
	repeat with m in theMacros
		try
			do script m
		end try
	end repeat
end tell