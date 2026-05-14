---
name: safeclaw-browser-use
description: |
  SafeClaw browser automation entrypoint with bundled Browser Harness runtime
  for macOS arm64 and Windows x64 white-environment use. Route SafeClaw browser
  work to Browser Harness for real Chrome takeover, logged-in browser work,
  screenshots, clicking, form filling, and CDP-driven inspection. Cookie
  import/export is an optional extension, not a default prerequisite.
allowed-tools:
  - Bash(./scripts/browser-harness:*)
  - Bash(scripts/browser-harness:*)
  - Bash(./scripts/browser-harness.cmd:*)
  - Bash(scripts/browser-harness.cmd:*)
  - Bash(python3:*)
  - Bash(powershell:*)
  - Bash(pwsh:*)
  - Bash(ps:*)
  - Bash(pgrep:*)
  - Bash(osascript:*)
  - Bash(open:*)
  - Bash(browser-harness:*)
---

# Browser Automation

This skill is the SafeClaw browser automation entrypoint.
SafeClaw browser automation must use Browser Harness:

1. Use this skill's bundled `scripts/browser-harness` launcher first. It carries
   the packaged Browser Harness runtime for white-environment use on macOS arm64.
   On Windows x64, use `scripts\browser-harness.cmd`.
2. Use `browser-use/browser-harness` for real Chrome takeover, logged-in pages,
   and screenshot/CDP-driven inspection.
3. Do not replace Browser Harness with Browser Use CLI, raw Chromium, browser
   MCP, Playwright, Puppeteer, Selenium, or another browser automation stack for
   SafeClaw workflows.

Cookie handling is optional. Do not run `cookie-manager` before ordinary
browser automation just because a site is logged in. Use Browser Harness with
the confirmed Chrome profile first.
Use cookie import/export only when a script, collector, CLI, or pipeline needs a
cookie file or when the user explicitly asks to import/export cookies.

Browser Harness source: https://github.com/browser-use/browser-harness

## Chrome Profile Gate

Every browser automation task must start by checking the user's local Chrome
profiles and identifying which Chrome profile is currently open. Show the
detected profiles to the user and ask which one SafeClaw should use. Once the
user chooses, bind the current task/session to that Chrome profile and keep
using it for all Browser Harness commands until the user
explicitly changes it.

An already-open Chrome window is reusable only if it is the confirmed target
profile. If Chrome is already open in a different profile, open a fresh Chrome
window or instance for the confirmed target profile with its explicit
`--profile-directory`; do not attach to the wrong profile, and do not ask the
user to close all Chrome windows.

Use Chrome's `Local State` file to list available profiles:

- macOS: `~/Library/Application Support/Google/Chrome/Local State`
- Windows: `$env:LOCALAPPDATA\Google\Chrome\User Data\Local State`

Use process arguments or OS browser state only to infer which profile is
currently open. If the current profile cannot be inferred, still show all
detected profiles and ask the user to choose. If no Chrome profiles exist, open a
new Chrome profile explicitly and bind the session to that new profile.

Do not use a clean Browser Use CLI session, a different Chrome profile, or a
throwaway Chromium profile when a confirmed real Chrome profile exists. If a
command cannot target the bound profile, stop and explain that limitation instead
of switching silently.

## Prerequisite Check

After the profile gate, run Browser Harness first:

```bash
./scripts/browser-harness --doctor
```

On Windows PowerShell:

```powershell
.\scripts\browser-harness.cmd --doctor
```

If the current working directory is not the skill directory, use the absolute
path to this skill's launcher. Use plain `browser-harness` only when SafeClaw has
already injected its managed bin directory into `PATH`.

If it is healthy, use Browser Harness. If it is missing, broken, or cannot attach
after the CDP repair flow below, stop browser automation. Do not continue to
Browser Use CLI, raw Chromium, browser MCP, Playwright, Puppeteer, Selenium, or
any other browser automation path; ask the user to try another information
source or repair `browser-harness`.

## CDP Permission Repair

When Browser Harness cannot connect to CDP for the confirmed profile, first try
to directly enable or re-open Chrome's "Allow remote debugging for this browser
instance" permission for that profile, then retry Browser Harness once. If the
direct repair does not work, open `chrome://inspect/#remote-debugging` in the
same confirmed profile and ask the user to turn on "Allow remote debugging for
this browser instance" manually. If Chrome shows an "Allow remote debugging?"
popup, wait for the user to click Allow.

On Windows, open the debug page with `chrome.exe` and the confirmed
`--profile-directory`; do not hand the `chrome://` URL to the system URL handler.
On macOS, open Chrome with the confirmed `--profile-directory` rather than the
default profile.

## Primary Browser Harness Workflow

1. Inspect or create the real browser tab:

```powershell
@'
ensure_real_tab()
print(page_info())
'@ | ./scripts/browser-harness
```

On Windows, replace `./scripts/browser-harness` with
`.\scripts\browser-harness.cmd`.

2. Navigate:

```powershell
@'
ensure_real_tab()
goto_url('https://example.com')
wait_for_load()
print(page_info())
'@ | ./scripts/browser-harness
```

3. Capture evidence before acting when the page is visual or brittle:

```powershell
@'
print(page_info())
print(capture_screenshot())
'@ | ./scripts/browser-harness
```

4. Interact narrowly and verify:

```powershell
@'
click_at_xy(420, 320)
fill_input('input[name=email]', 'user@example.com')
press_key('Enter')
print(page_info())
'@ | ./scripts/browser-harness
```

Do not loop on Browser Harness failures. Retry once if the error is clearly a stale
tab or daemon issue. For CDP attach failures, run the CDP permission repair flow,
then stop browser automation if Browser Harness still cannot attach.

## Browser Selection Priority

The primary goal is stable browser reuse with the confirmed Chrome profile:

1. Browser Harness real Chrome takeover for all logged-in or user-specific work.
2. Browser Harness CDP permission repair when the confirmed profile cannot attach.
3. Headed user interaction only when the user must complete CAPTCHA, MFA, OAuth,
   payment confirmation, or another visible check.

Do not switch modes just because a command failed once. First identify whether the
failure is dependency, session, authentication, page state, or anti-bot related.

## SafeClaw Session Rules

- Prefer Browser Harness with the confirmed Chrome profile for normal work.
- If the currently open Chrome profile is not the confirmed target profile,
  open a new target-profile Chrome window and bind Browser Harness to that
  window; never continue in the wrong profile just because Chrome is already
  open.
- Do not repeatedly reopen the same URL just to check state; inspect the current session first.
- For authenticated sites, do not treat cookie import as mandatory. For direct browser work, use Browser Harness to reuse the confirmed real Chrome session. Use `cookie-manager` only when SafeClaw local pipelines need exported cookies or a reusable `cookies_path`.
- If remote debugging is not enabled and CDP attach fails, run the CDP permission repair flow before asking the user to manually use the debug page.

## Fallback Policy

Use this order when browser automation is unstable:

1. Profile not bound: inspect Chrome profiles, identify the current profile if
   possible, ask the user to choose, then bind the session to that profile.
2. Browser Harness dependency failure: stop browser automation and report that
   `browser-harness` needs repair.
3. Browser Harness CDP failure: directly repair the confirmed profile's remote
   debugging permission, retry once, then open the debug page for manual user
   confirmation and retry once.
4. Stale or broken Browser Harness tab/session: retry once in the same confirmed
   profile.
5. Persistent failure: report the exact stuck step, tell the user browser
   automation failed, and try a non-browser information source only if the task
   supports one.

Never hide failures by repeatedly opening new tabs, new sessions, or clean browser
profiles. Preserve the user's working browser state whenever possible.

## Compatibility Note

This skill replaces the old SafeClaw `browser-use` ability ID. SafeClaw browser
automation should still execute through `browser-harness`. If a task cannot be
done through Browser Harness, report the blocked step and use a non-browser
source or manual import when the workflow allows it.
