-- Slack "now playing" from YouTube in Safari (always on)
-- Checks Safari every 60 seconds, updates your Slack status only when the song changes,
-- and clears it when no YouTube video is open. Save it as an app with Automator to run it in the background.

property lastTitle : ""

log "=== AUTO SCRIPT STARTED (SAFARI) ==="

-- CONFIG
set slackToken to "PASTE_YOUR_XOXP_TOKEN_HERE"
set statusEmoji to ":headphones:"
set slackAPI to "https://slack.com/api/users.profile.set"

repeat
	try
		tell application "Safari"
			if not running then
				set tabTitle to missing value
				set tabURL to ""
			else
				try
					set tabURL to URL of front document
					set tabTitle to name of front document
				on error
					set tabTitle to missing value
					set tabURL to ""
				end try
			end if
		end tell

		if tabURL contains "youtube.com/watch" then
			-- Clean title
			set cleanTitle to tabTitle
			set AppleScript's text item delimiters to " - YouTube"
			set cleanTitle to text item 1 of cleanTitle
			set AppleScript's text item delimiters to ""

			-- Only update when the song changes
			if cleanTitle ≠ lastTitle then
				set lastTitle to cleanTitle
				log "Updating Slack: " & cleanTitle
				set jsonPayload to "{ \"profile\": { \"status_text\": \"🎶 " & cleanTitle & "\", \"status_emoji\": \"" & statusEmoji & "\" } }"
				do shell script "curl -s -X POST " & slackAPI & " -H 'Authorization: Bearer " & slackToken & "' -H 'Content-Type: application/json; charset=utf-8' --data '" & jsonPayload & "'"
			end if
		else
			-- Clear the status when there's no YouTube video
			if lastTitle ≠ "" then
				log "Clearing Slack status (no YouTube open)"
				set lastTitle to ""
				set jsonPayload to "{ \"profile\": { \"status_text\": \"\", \"status_emoji\": \"\" } }"
				do shell script "curl -s -X POST " & slackAPI & " -H 'Authorization: Bearer " & slackToken & "' -H 'Content-Type: application/json; charset=utf-8' --data '" & jsonPayload & "'"
			end if
		end if
	on error errMsg
		log "Error in loop: " & errMsg
	end try

	delay 60
end repeat
