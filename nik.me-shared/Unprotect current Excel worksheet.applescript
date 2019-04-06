set pwd to ""
set pn to 194560
set pc to 0

set progress total steps to pn

repeat with i from 65 to 66
	repeat with j from 65 to 66
		repeat with k from 65 to 66
			repeat with l from 65 to 66
				repeat with m from 65 to 66
					repeat with i1 from 65 to 66
						repeat with i2 from 65 to 66
							repeat with i3 from 65 to 66
								repeat with i4 from 65 to 66
									repeat with i5 from 65 to 66
										repeat with i6 from 65 to 66
											repeat with n from 32 to 126
												
												set pwd to (i & j & k & l & m & i1 & i2 & i3 & i4 & i5 & i6 & n) as text
												
												
												
												tell application "Microsoft Excel"
													tell active workbook to tell active sheet
														
														if protect contents then
															unprotect password pwd
														else
															set the clipboard to pwd
															display alert "Sheet can be unlocked with the password \"" & pwd & "\". This password has been copied to your clipboard."
															return pwd
														end if
													end tell
												end tell
												
												set pc to pc + 1
												
												set progress completed steps to pc
												
											end repeat
										end repeat
									end repeat
								end repeat
							end repeat
						end repeat
					end repeat
				end repeat
			end repeat
		end repeat
	end repeat
end repeat

