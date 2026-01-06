-- Slack "now playing" from YouTube in Safari (run once)
-- Reads the YouTube video in Safari's front tab and sets it as your Slack status.
-- Safari can stay in the background. Open View > Show Log in Script Editor to follow each step.

log "=== SCRIPT STARTED (SAFARI) ==="

-- CONFIG
set slackToken to "PASTE_YOUR_XOXP_TOKEN_HERE"
set statusEmoji to ":headphones:"

tell application "Safari"
	if not running then
		log "Safari is not running"
		return
	end if

	try
		set tabURL to URL of front document
		set tabTitle to name of front document

		log "Active URL (Safari): " & tabURL
		log "Active title (Safari): " & tabTitle
	on error errMsg
		log "Could not read Safari: " & errMsg
		return
	end try
end tell

if tabURL does not contain "youtube.com/watch" then
	log "Active tab is not YouTube"
	return
end if

-- CLEAN TITLE
set cleanTitle to tabTitle
set AppleScript's text item delimiters to " - YouTube"
set cleanTitle to text item 1 of cleanTitle
set AppleScript's text item delimiters to ""

log "Clean title: " & cleanTitle

-- SLACK
set slackAPI to "https://slack.com/api/users.profile.set"
set jsonPayload to "{ \"profile\": { \"status_text\": \"🎶 " & cleanTitle & "\", \"status_emoji\": \"" & statusEmoji & "\" } }"

log "Sending status to Slack..."

do shell script "curl -s -X POST " & slackAPI & " -H 'Authorization: Bearer " & slackToken & "' -H 'Content-Type: application/json; charset=utf-8' --data '" & jsonPayload & "'"

log "STATUS UPDATED"
