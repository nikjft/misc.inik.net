-- Nik's Crappy Scripts Library Version: 0.1

property appName : "Nik's crappy scripts"
property appDomain : "me.nik.crappyscripts"
property libVersion : 0.2
property updateURL : "http://misc.inik.net/ncslib.applescript"

on run
	-- nullop, this probably should be unit tests or something
end run


(* GROWL NOTIFICATIONS *)

-- Example: growlNotify("Alert","This is an Alert","This is a test of the Growl Alert System")
on growlNotify(grrName, grrTitle, grrDescription)
	tell application "Growl"
		my growlRegister() -- Register if it hasn't alerted yet
		notify with name grrName title grrTitle description grrDescription application name appName
	end tell
end growlNotify

-- Does not have to be called directly. Growl notifications will always invoke it.
on growlRegister()
	tell application "Growl"
		register as application appName all notifications {"Alert", "Message", "Debug"} default notifications {"Alert", "Message"} icon of application "Script Editor.app"
	end tell
end growlRegister

(* URL FUNCTIONS *)

-- Shortens a URL using the is.gd service
on shortenURL(longURL)
	do shell script "curl 'http://is.gd/create.php?format=simple&url=" & my urlEncode(longURL) & "'"
	return result
end shortenURL

-- encode string so it's URL-safe
on urlEncode(decodedString)
	do shell script "echo " & quoted form of Â
		decodedString & " | /usr/bin/ruby -r cgi -e \"print CGI.escape(STDIN.read.strip).gsub('+','%20')\""
end urlEncode

-- decode URL encoded string
on urlDecode(encodedString)
	do shell script "echo " & quoted form of Â
		encodedString & " | /usr/bin/ruby -r cgi -e \"print CGI.unescape(STDIN.read.strip).gsub('+',' ')\""
end urlDecode

-- URI Object: A class/object of URI which contains properties for the url scheme, location and arguments, as passed through an initializing URL

on newURIObject(u)
	script uriObject
		
		property rawURL : missing value
		property scheme : missing value
		property location : missing value
		property args : {}
		
		(* initialize()		
		This handler initializes the URL object, breaking it out into its constituent parts, and assigns them to the various script object properties. It will also replace and overwrite any existing URL properties on the script object *)
		
		on initialize(aURL)
			try
				
				set u to aURL
				-- Break out the URL into its various components
				set theSplitURL to splitURL(aURL)
				log result
				--Get the URI-Scheme from the URI
				set scheme to item 1 of theSplitURL
				-- Get the location from the URI
				set location to (decode_text(item 2 of theSplitURL))
				
				-- parse arguments
				if item 2 of theSplitURL is not missing value then
					set args to argsToRecord(item 3 of theSplitURL)
				end if
				
				-- All went well, let's reset our text item delimiters and send back the arguments
				set AppleScript's text item delimiters to ""
				return {scheme:scheme, location:location, args:args}
				
			on error errMsg number errNum
				display alert errMsg & " (" & errNum & ")"
				error number -128
			end try
		end initialize
		
		
		
		(* Convert a URL into a record set *)
		on splitURL(theURL)
			set theArgs to {}
			set text item delimiters to ":"
			set theURI to text item 1 of theURL
			set text item delimiters to ""
			set uriN to (count of characters of theURI) + 1 -- account for the ":"
			-- Get rid of the url protocol string
			
			set pN to offset of (theURI & "://") in theURL -- is it a mailto:// style?
			
			if pN > 0 then -- a URI:// url
				set theURL to text (uriN + 3) through (count of characters of theURL) of theURL
			else -- or just a URI: url
				set theURL to text (uriN + 1) through (count of characters of theURL) of theURL
			end if
			
			-- See if there's any arguments being passed, pass 'em back if there are
			set aN to offset of "?" in theURL
			if aN = 1 then -- no base url, just arguments
				return {missing value, (text (aN + 1) through (count of characters of theURL) of theURL)}
			else if aN > 1 then
				return {theURI, (text 1 through (aN - 1) of theURL), (text (aN + 1) through (count of characters of theURL) of theURL)}
			else
				return {theURI, theURL, theArgs}
			end if
			
		end splitURL
		
		(* Splits ?key=value&key2=value2 type arguments from the URI and turns them into a {key:value,key2:value2} record set *)
		on argsToRecord(argString)
			set rStringArray to {}
			set text item delimiters to "&"
			set splitArgs to text items of argString
			set text item delimiters to "="
			
			repeat with a in splitArgs
				set ax to text items of a
				set axKey to item 1 of ax
				set axValue to my decode_text(item 2 of ax)
				set rStringArray to rStringArray & {axKey & ":\"" & axValue & "\""}
			end repeat
			set text item delimiters to ","
			run script ("return {" & rStringArray as string) & "}"
			return result
		end argsToRecord
		
		(* Simple HTML decode routine *)
		on decode_text(encodedString)
			do shell script "echo " & quoted form of Â
				encodedString & " | /usr/bin/ruby -r cgi -e \"print CGI.unescape(STDIN.read).gsub('+',' ')\""
		end decode_text
	end script
	-- Fire it off immediately so we have a full URL Object when all is said and done
	tell uriObject to initialize(u)
	return uriObject
end newURIObject


(* FINDER & FILE FUNCTIONS *)

-- Get the folder of the frontmost Finder window, or the desktop if there are no open windows. This handler does not respect focus on the desktop.

on getFinderActiveFolder()
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
end getFinderActiveFolder

-- Create a unique file name by incrementing a number at the end of the name.

on makeUniqueFileName(filename, destination)
	tell application "Finder"
		set i to 0
		set AppleScript's text item delimiters to "."
		set tiName to text items of filename
		set AppleScript's text item delimiters to ""
		set tiCount to count of tiName
		
		if tiCount > 1 then
			set baseExt to last item of tiName
			set baseName to items 1 through (tiCount - 1) of tiName as string
		else
			set baseName to filename
			set baseExt to ""
		end if
		
		repeat
			if i = 0 then
				set targetName to baseName & "." & baseExt
			else
				set targetName to baseName & " " & i & "." & baseExt
			end if
			
			set i to i + 1
			
			try
				get file targetName of destination
			on error
				return targetName
			end try
		end repeat
	end tell
end makeUniqueFileName

-- Get the date added property from a disk item
on getFileDateAdded(theFile)
	set aFilePath to POSIX path of theFile
	do shell script "mdls -name kMDItemDateAdded -raw " & (quoted form of aFilePath)
	do shell script "ruby -e \"require 'date'\" -e \"puts DateTime.parse('" & result & "').strftime('%m-%d-%Y')\""
	run script ("get date \"" & result & "\"")
	return result
end getFileDateAdded

-- Get all files in a folder recursively
on getRecursiveFolderContents(theFolder)
	tell application "Finder"
		set theFiles to every file of (entire contents of folder theFolder) as alias list
	end tell
end getRecursiveFolderContents

(* SEARCH FUNCTIONS *)

-- Run a spotlight search. Requires LaunchBar to execute it.

on doSpotlightSearch(searchString)
	tell application "LaunchBar"
		perform action "Search in Spotlight" with string searchString
	end tell
end doSpotlightSearch




(* SHELL AND TERMINAL FUNCTIONS *)

-- Run a shell command in the Terminal within a new tab, as opposed to within a new window

on doScriptInNewTerminalTab(cmd)
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
end doScriptInNewTerminalTab


(* SYSTEM FUNCTIONS *)

-- Get the total size of all displays on computer. Dock sizes are rough estimates.
on getDisplayDimensions()
	tell application "Finder" to get bounds of window of desktop
	set {display_L, display_T, display_R, display_B} to result
	
	tell application "System Events" to get dock size of dock preferences
	set dock_height to result * 128 + 16 -- Get size of dock
	set display_width to display_R - display_L
	set display_height to display_B - dock_height
	set theResults to {display_L:display_L, display_T:display_T, display_R:display_R, display_width:display_width, display_height:display_height, display_height_abovedock:display_height - dock_height, dock_height:dock_height}
	return theResults
end getDisplayDimensions

(* STRING AND NUMBER FUNCTIONS *)

-- Escapes quotation marks in a string so that it can be used for AppleScripts
on escapeStringForAppleScript(theString)
	do shell script "echo " & quoted form of theString & "  | ruby -e \"print STDIN.read.gsub('\\\\\\\\','\\\\\\\\\\\\\\\\\\\\\\\\').gsub('\\\"','\\\\\\\"')\""
end escapeStringForAppleScript

-- Sort list in ascending order. Differs from Finder order in that numbers are "lower" than letters.
on sortAscending(theList)
	set oldTID to text item delimiters
	set text item delimiters to {ASCII character 10} -- linefeed
	set theListString to (theList as string)
	log theListString
	set theListStringSorted to do shell script "echo " & quoted form of theListString & " | sort -fg"
	set theListSorted to (every paragraph of theListStringSorted)
	set AppleScript's text item delimiters to oldTID
	return theListSorted
end sortAscending

-- Sort list in descending order. Differs from Finder order in that numbers are "lower" than letters.
on sortDescending(theList)
	set oldTID to text item delimiters
	set text item delimiters to {ASCII character 10} -- linefeed
	set theListString to (theList as string)
	log theListString
	set theListStringSorted to do shell script "echo " & quoted form of theListString & " | sort -fgr"
	set theListSorted to (every paragraph of theListStringSorted)
	set AppleScript's text item delimiters to oldTID
	return theListSorted
end sortDescending


(* META-LIBRARY FUNCTIONS: Handling the behavior and updating of this library. *)

-- Check script version for compatability

on getLibVersion()
	return libVersion
end getLibVersion

on checkLibVersion(targetVersion)
	if libVersion is greater than targetVersion then
		return libVersion
	else
		error "Library version " & libVersion & " is lower than target version " & targetVersion & ". Check " & updateURL & " for a more recent version." number 2
	end if
end checkLibVersion

-- Manage application ID for defaults in preferences, app support folders, notifications, etc.

on setAppID(theAppName, theAppDomain)
	set appName to theAppName
	set appDomain to theAppDomain
end setAppID

on getAppID()
	return {appName:appName, appDomain:appDomain}
end getAppID

(* Load Library: This should be copied into scripts that require ncslib support. Managed installation (downloading), loading, and auto-updating of the script library. Returns a script object on success. *)

on LoadNCSLib(targetVersion)
	
	tell application "Finder"
		try
			
			-- Load it up
			set ncsLibFile to (file ncslibFileName of folder ncsAppSupportFolderName of (path to application support folder from user domain)) as alias
			set ncslib to load script ncsLibFile
			set ncsLibVersion to ncslib's getLibVersion()
			
			if ncsLibVersion < targetVersion then
				delete ncsLibFile -- Start clean
				my LoadNCSLib(targetVersion)
			else
				return ncslib
			end if
			
			-- Can't load it or wrong version	
		on error errMsg number errNum
			set ncslibAppSupportFolderPath to (POSIX path of (path to application support folder from user domain) & ncsAppSupportFolderName)
			do shell script "mkdir -p " & quoted form of ncslibAppSupportFolderPath
			do shell script "curl -s " & ncslibURL & " | osacompile -o " & quoted form of (ncslibAppSupportFolderPath & "/" & ncslibFileName)
			-- let's try again now that we've downloaded it
			set ncsLibFile to (file ncslibFileName of folder ncsAppSupportFolderName of (path to application support folder from user domain)) as alias
			set ncslib to load script (ncsLibFile as alias)
			
			set ncsLibVersion to ncslib's getLibVersion()
			
			-- Check version, error if out-of-date
			if ncsLibVersion < targetVersion then
				error "Script requires ncslib.scpt version " & targetVersion & ". Latest version available online is " & ncslib's getLibVersion() & "."
			else
				return ncslib
			end if
		end try
		return ncslib
	end tell
end LoadNCSLib