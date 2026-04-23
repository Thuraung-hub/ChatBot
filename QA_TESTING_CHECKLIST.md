# 🧪 QA Testing Checklist - Pinky Shop Chatbot Flutter Web App

**App URL:** https://pinky-shop-f5ad6.web.app  
**Testing Environment:** Chrome/Firefox/Safari (Web)  
**Date:** April 14, 2026  
**Status:** Active Testing

---

## 📋 TABLE OF CONTENTS
1. [User Authentication](#1-user-authentication)
2. [Forgot Password Functionality](#2-forgot-password-functionality)
3. [Chatbot Messaging System](#3-chatbot-messaging-system)
4. [API Response Handling](#4-api-response-handling)
5. [UI Responsiveness](#5-ui-responsiveness)
6. [Error Handling & Edge Cases](#6-error-handling--edge-cases)
7. [Browser Console Checks](#7-browser-console-checks)
8. [Performance Issues](#8-performance-issues)

---

## 1. USER AUTHENTICATION

### 1.1 Email/Password Login

#### ✅ TC-AUTH-001: Valid Email and Password Login
**Description:** User logs in with correct email and password credentials

**Steps to Execute:**
1. Navigate to https://pinky-shop-f5ad6.web.app
2. Click on "Login" button on welcome screen
3. Enter valid email: `test@example.com`
4. Enter valid password: `Password123`
5. Click "Login" button
6. Wait for authentication response

**Expected Result:**
- ✓ Navigation to home/dashboard screen succeeds
- ✓ User data loads (name, profile picture if available)
- ✓ Chatbot interface displays
- ✓ No errors in browser console
- ✓ Authentication token stored in localStorage/sessionStorage

**Possible Failure Scenarios:**
- ❌ Error message: "Invalid credentials"
- ❌ Blank white screen (authentication stuck)
- ❌ Firebase error: "USER_DISABLED"
- ❌ Network timeout
- ❌ CORS error in console

**Pass/Fail:** ☐ PASS / ☐ FAIL  
**Notes:** ___________________________

---

#### ✅ TC-AUTH-002: Invalid Email Format
**Description:** User attempts login with incorrectly formatted email

**Steps to Execute:**
1. Go to login screen
2. Enter email: `notanemail` (without @)
3. Enter any password
4. Click "Login" button
5. Check form validation

**Expected Result:**
- ✓ Red error message appears below email field
- ✓ Error text: "Please enter a valid email address"
- ✓ Login button remains disabled/grayed out
- ✓ No API call is made (form validation stops it)

**Possible Failure Scenarios:**
- ❌ Form allows submission with invalid email
- ❌ API call made despite invalid format
- ❌ No error message displayed
- ❌ Validation error appears after server response

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-003: Empty Email Field
**Description:** User attempts login with empty email

**Steps to Execute:**
1. Go to login screen
2. Leave email field empty
3. Enter password: `Password123`
4. Click "Login" button

**Expected Result:**
- ✓ Validation error: "Email is required"
- ✓ Login button stays disabled
- ✓ Focus remains on email field

**Possible Failure Scenarios:**
- ❌ Form submitted with empty email
- ❌ Generic error instead of specific message

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-004: Empty Password Field
**Description:** User attempts login with empty password

**Steps to Execute:**
1. Go to login screen
2. Enter email: `test@example.com`
3. Leave password field empty
4. Click "Login" button

**Expected Result:**
- ✓ Validation error: "Password is required" or "Password must be at least 6 characters"
- ✓ Login button disabled
- ✓ No authentication attempt

**Possible Failure Scenarios:**
- ❌ Validation bypassed
- ❌ Account logged in with no password

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-005: Incorrect Password
**Description:** User enters correct email but wrong password

**Steps to Execute:**
1. Go to login screen
2. Enter email: `test@example.com`
3. Enter wrong password: `WrongPassword`
4. Click "Login" button
5. Wait for server response

**Expected Result:**
- ✓ Error message appears: "Invalid email or password"
- ✓ User remains on login screen
- ✓ Login button becomes enabled again (not stuck)
- ✓ Password field clears on re-focus
- ✓ No sensitive data exposed in error

**Possible Failure Scenarios:**
- ❌ Generic Firebase error exposed
- ❌ Login button stuck in loading state
- ❌ Different error for existing vs non-existing accounts (account enumeration)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-006: SQL Injection Attempt in Email
**Description:** User attempts SQL injection in email field

**Steps to Execute:**
1. Go to login screen
2. Enter email: `test' OR '1'='1`
3. Enter password: `anything`
4. Click "Login"

**Expected Result:**
- ✓ Form validation catches invalid email format
- ✓ OR alert error message
- ✓ No database injection occurs
- ✓ Firebase safely ignores the malicious input

**Possible Failure Scenarios:**
- ❌ Injection attempt processed
- ❌ Unexpected data retrieved

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 1.2 Email/Password Signup

#### ✅ TC-AUTH-007: Valid Signup with All Fields
**Description:** New user creates account with valid data

**Steps to Execute:**
1. Go to login screen
2. Click "Create Account" link
3. Fill registration form:
   - Name: `John Doe`
   - Email: `newuser@example.com` (unique)
   - Password: `SecurePass123`
   - Confirm accept Privacy Policy checkbox
4. Click "Create Account" button
5. Wait for account creation

**Expected Result:**
- ✓ Account created successfully
- ✓ Automatic login occurs
- ✓ Redirected to home/dashboard screen
- ✓ User profile displays with entered name
- ✓ Success notification shows (optional)
- ✓ Navigation bar shows user name

**Possible Failure Scenarios:**
- ❌ "Email already exists" error when email is new
- ❌ Account not created but user logged in
- ❌ Policy checkbox reset on page reload
- ❌ Password requirements not met error unclear

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-008: Signup with Existing Email
**Description:** User tries to register with already-registered email

**Steps to Execute:**
1. Go to signup screen
2. Enter existing email: `test@example.com`
3. Enter name: `Duplicate User`
4. Enter new password: `NewPassword123`
5. Accept policy
6. Click "Create Account"

**Expected Result:**
- ✓ Error message: "This email is already registered"
- ✓ User remains on signup form (not logged in)
- ✓ All fields retain their values (except optional reload)
- ✓ No account created

**Possible Failure Scenarios:**
- ❌ Account created with duplicate email
- ❌ Generic Firebase error shown
- ❌ Silent failure (user thinks account created)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-009: Signup Without Accepting Policy
**Description:** User tries to register without checking privacy policy

**Steps to Execute:**
1. Go to signup screen
2. Fill all fields correctly:
   - Name: `Jane Doe`
   - Email: `jane@example.com`
   - Password: `SecurePass123`
3. **Leave policy checkbox unchecked**
4. Click "Create Account" button

**Expected Result:**
- ✓ Error message appears: "You must accept the Privacy Policy and User Agreement"
- ✓ Signup button remains disabled or shows error state
- ✓ No account created
- ✓ User must check box to proceed

**Possible Failure Scenarios:**
- ❌ Account created without policy acceptance
- ❌ Checkbox validation ignored
- ❌ No error message shown

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-010: Weak Password Validation
**Description:** User enters password that doesn't meet requirements

**Steps to Execute:**
1. Go to signup screen
2. Enter name: `Test User`
3. Enter email: `test123@example.com`
4. Enter weak password: `123` (too short)
5. Click "Create Account"

**Expected Result:**
- ✓ Error message: "Password must be at least 6 characters"
- ✓ Signup button disabled
- ✓ No account created

**Possible Failure Scenarios:**
- ❌ Account created with weak password
- ❌ Vague error message
- ❌ Client-side validation bypassed via DevTools

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 1.3 Google Sign-In (OAuth)

#### ✅ TC-AUTH-011: Google Sign-In Success
**Description:** User successfully logs in with Google account

**Steps to Execute:**
1. Navigate to https://pinky-shop-f5ad6.web.app
2. Click "Google Account" button on login screen
3. Google sign-in popup appears
4. Select a valid Google account
5. Grant permissions when prompted
6. Wait for redirect

**Expected Result:**
- ✓ Google popup opens (not blocked)
- ✓ After auth, button shows "Processing..."
- ✓ User redirected to dashboard
- ✓ User name/email from Google Account displays
- ✓ Profile picture loads (if available)
- ✓ No console errors (except CORS preflight if expected)

**Possible Failure Scenarios:**
- ❌ Error: "This domain is not authorized for OAuth operations"
- ❌ Popup blocked by browser
- ❌ Google popup closes without action
- ❌ Stuck on "Processing..." indefinitely
- ❌ "CONFIGURATION_MISMATCH" error
- ❌ User data not loaded after auth

**Pass/Fail:** ☐ PASS / ☐ FAIL  
**Note:** This was fixed by adding pinky-shop-f5ad6.web.app to authorized domains

---

#### ✅ TC-AUTH-012: Google Sign-In with PopUp Blocked
**Description:** User attempts Google sign-in when popup is blocked

**Steps to Execute:**
1. Disable popups in browser settings
2. Go to login screen
3. Click "Google Account" button
4. Observe behavior

**Expected Result:**
- ✓ User sees clear error: "Popup was blocked. Please enable popups and try again"
- ✓ User can retry after enabling popups
- ✓ App doesn't hang

**Possible Failure Scenarios:**
- ❌ Silent failure (nothing happens)
- ❌ Generic Firebase error
- ❌ App becomes unresponsive

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-013: Google Sign-In Cancel
**Description:** User cancels Google authentication popup

**Steps to Execute:**
1. Go to login screen
2. Click "Google Account" button
3. Google popup appears
4. Click "Cancel" or close popup
5. Observe app behavior

**Expected Result:**
- ✓ Popup closes
- ✓ App returns to login screen (no error)
- ✓ User can retry login
- ✓ Loading state clears

**Possible Failure Scenarios:**
- ❌ App shows error instead of graceful cancel
- ❌ Loading button stuck
- ❌ Stack trace in console

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-014: Google Sign-In New User Auto-Registration
**Description:** New Google user automatically creates account on first login

**Steps to Execute:**
1. Use a new Google account (never used with app before)
2. Click "Google Account" login button
3. Complete Google auth
4. Observe account creation

**Expected Result:**
- ✓ Account created automatically with Google data (email, name)
- ✓ User logged in and redirected to dashboard
- ✓ User profile shows correct name from Google
- ✓ No signup form shown (seamless registration)

**Possible Failure Scenarios:**
- ❌ Account not created, auth fails
- ❌ User data not fetched from Google
- ❌ Partial data missing (email but no name)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 1.4 Session Management

#### ✅ TC-AUTH-015: Session Persistence After Refresh
**Description:** User remains logged in after browser refresh

**Steps to Execute:**
1. Login with valid credentials
2. Wait for dashboard to load
3. Press F5 or click refresh button
4. Wait for page to load

**Expected Result:**
- ✓ Page reloads without showing login screen
- ✓ User remains logged in
- ✓ User data persists (name, chat history visible)
- ✓ No re-login required

**Possible Failure Scenarios:**
- ❌ Redirect to login screen after refresh
- ❌ Session token not stored
- ❌ Blank white screen

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-016: Logout Functionality
**Description:** User successfully logs out of account

**Steps to Execute:**
1. Login with valid credentials
2. Navigate to dashboard
3. Find and click "Logout" button (usually in menu/profile)
4. Observe redirect

**Expected Result:**
- ✓ User redirected to login screen
- ✓ Session token cleared
- ✓ Pressing back doesn't re-login
- ✓ Refresh shows login screen
- ✓ Local data cleared (except non-sensitive)

**Possible Failure Scenarios:**
- ❌ Logout button missing
- ❌ User remains logged in after logout
- ❌ Browser back button logs user in again

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-AUTH-017: Session Timeout
**Description:** Long inactive session expires as expected

**Steps to Execute:**
1. Login successfully
2. Let browser idle for 30+ minutes (or configure timeout value)
3. Try to interact with app (send message, navigate)

**Expected Result:**
- ✓ Session expires
- ✓ User redirected to login screen
- ✓ Message: "Your session has expired. Please login again"
- ✓ No console errors

**Possible Failure Scenarios:**
- ❌ Session never expires (security risk)
- ❌ App crashes on timeout
- ❌ Partial requests still go through

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 2. FORGOT PASSWORD FUNCTIONALITY

### 2.1 Password Reset Flow

#### ✅ TC-PWD-001: Valid Email Password Reset
**Description:** User successfully initiates password reset

**Steps to Execute:**
1. Go to login screen
2. Click "Forgot Password?" link
3. Enter registered email: `test@example.com`
4. Click "Send Reset Email" button
5. Check email inbox

**Expected Result:**
- ✓ Success message: "Password reset email sent successfully"
- ✓ No error in console
- ✓ Email received within 2-5 minutes (in real Firebase projects)
- ✓ Email contains reset link
- ✓ User redirected to login or reset confirmation page

**Possible Failure Scenarios:**
- ❌ "Failed to send email" error
- ❌ No email received
- ❌ Email link expired
- ❌ SMTP configuration issue

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-002: Non-Registered Email Password Reset
**Description:** User tries to reset password for non-existent email

**Steps to Execute:**
1. Go to forgot password page
2. Enter non-existent email: `nonexistent@example.com`
3. Click "Send Reset Email"
4. Observe response

**Expected Result:**
- ✓ **Security Practice**: Message says "If this email exists, reset link sent" (no account enumeration)
- ✓ OR Firebase returns: "There is no user record matching this email"
- ✓ No email sent

**Possible Failure Scenarios:**
- ❌ Different message for existing vs non-existing (account enumeration risk)
- ❌ Email sent to wrong address
- ❌ Console error exposed

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-003: Invalid Email Format in Reset
**Description:** User enters invalid email format in password reset

**Steps to Execute:**
1. Go to forgot password page
2. Enter invalid email: `notanemail`
3. Click "Send Reset Email"

**Expected Result:**
- ✓ Validation error: "Please enter a valid email address"
- ✓ Button remains disabled
- ✓ No API call made

**Possible Failure Scenarios:**
- ❌ Request sent with invalid email
- ❌ Generic server error

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-004: Empty Email in Reset Form
**Description:** User leaves email empty in password reset

**Steps to Execute:**
1. Go to forgot password page
2. Leave email field empty
3. Click "Send Reset Email"

**Expected Result:**
- ✓ Error: "Email is required"
- ✓ Button disabled

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 2.2 Reset Link Validation

#### ✅ TC-PWD-005: Click Password Reset Link
**Description:** User clicks password reset link from email

**Steps to Execute:**
1. Receive password reset email
2. Click reset link in email
3. Wait for password reset page to load

**Expected Result:**
- ✓ Reset code/token validated
- ✓ Password reset form displays
- ✓ Fields: New Password, Confirm Password
- ✓ No errors

**Possible Failure Scenarios:**
- ❌ "Invalid or expired reset link"
- ❌ Blank page or 404
- ❌ Page loads but form errors on submission

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-006: Expired Reset Link
**Description:** User clicks password reset link after expiration (usually 1 hour)

**Steps to Execute:**
1. Receive password reset email
2. Wait 60+ minutes
3. Click reset link
4. Try to reset password

**Expected Result:**
- ✓ Error: "Reset link has expired. Please request a new one"
- ✓ Back link to login or new reset request
- ✓ Security maintained

**Possible Failure Scenarios:**
- ❌ Expired link still works (security risk)
- ❌ Vague error message

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-007: Reset Link with Invalid Token
**Description:** User tampers with reset link token

**Steps to Execute:**
1. Get password reset link from email
2. Modify token part in URL manually
3. Press Enter to navigate
4. Try to submit new password

**Expected Result:**
- ✓ Error: "Invalid reset token" or "Link is no longer valid"
- ✓ Page doesn't process the form
- ✓ Security maintained

**Possible Failure Scenarios:**
- ❌ Password changed with fake token
- ❌ No validation of token

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 2.3 New Password Validation

#### ✅ TC-PWD-008: Set Valid New Password
**Description:** User successfully sets new password after reset

**Steps to Execute:**
1. Navigate to password reset page (via valid link)
2. Enter new password: `NewPassword123`
3. Confirm password: `NewPassword123`
4. Click "Reset Password" button
5. Wait for success message

**Expected Result:**
- ✓ Success: "Password has been reset successfully"
- ✓ Redirect to login page
- ✓ Old password no longer works
- ✓ New password works for login

**Possible Failure Scenarios:**
- ❌ "Passwords don't match" error when they do
- ❌ Password not updated in database
- ❌ Stuck in "Processing" state

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-009: Password Mismatch in Reset
**Description:** User enters mismatching passwords in reset form

**Steps to Execute:**
1. Go to password reset page
2. Enter password: `NewPassword123`
3. Confirm password: `DifferentPassword`
4. Click "Reset Password"

**Expected Result:**
- ✓ Error: "Passwords do not match"
- ✓ Button remains disabled
- ✓ No submission to server

**Possible Failure Scenarios:**
- ❌ Passwords accepted despite mismatch
- ❌ Server error instead of client validation

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-010: Weak New Password
**Description:** User tries to set weak password (less than 6 chars)

**Steps to Execute:**
1. Go to password reset page
2. Enter password: `123`
3. Confirm password: `123`
4. Click "Reset Password"

**Expected Result:**
- ✓ Error: "Password must be at least 6 characters"
- ✓ Button disabled

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PWD-011: Reset with Old Password
**Description:** User tries to set same password as old one

**Steps to Execute:**
1. Know user's old password: `OldPassword123`
2. Go through reset flow
3. Try to set same password: `OldPassword123`
4. Click "Reset Password"

**Expected Result:**
- ✓ **Best practice**: Either allow (Firebase default) or prevent with message
- ✓ If prevented: "New password must be different from current password"
- ✓ If allowed: Password reset succeeds

**Possible Failure Scenarios:**
- ❌ Server error when old password used

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 3. CHATBOT MESSAGING SYSTEM

### 3.1 Basic Messaging

#### ✅ TC-CHAT-001: Send Simple Text Message
**Description:** User sends a basic text message to chatbot

**Steps to Execute:**
1. Login and navigate to chat screen
2. Click on message input field
3. Type: `Hello, how are you?`
4. Press Enter or click Send button
5. Wait for response

**Expected Result:**
- ✓ Message appears in chat bubble from user (right side, different color)
- ✓ Message sends immediately (within 500ms)
- ✓ Message timestamp displays
- ✓ Input field clears
- ✓ Cursor focuses back to input
- ✓ Scroll auto-moves to latest message

**Possible Failure Scenarios:**
- ❌ Message doesn't appear
- ❌ "Send" button stuck in loading state
- ❌ Message duplicates on send
- ❌ Chat doesn't scroll to bottom
- ❌ Network error in console

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-002: Receive Chatbot Response
**Description:** Chatbot responds to user message

**Steps to Execute:**
1. Send message: `What products do you have?`
2. Wait for chatbot response (typically 1-3 seconds)
3. Observe response in chat

**Expected Result:**
- ✓ Chatbot response appears in bubble (left side, different color)
- ✓ Response has typing indicator before appearing (optional)
- ✓ Response displays completely
- ✓ Response includes relevant information or product links
- ✓ Timestamp shows

**Possible Failure Scenarios:**
- ❌ No response from chatbot
- ❌ Generic error response
- ❌ Timeout error
- ❌ Incomplete message (cut off)
- ❌ Loading spinner never stops

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-003: Send Empty Message
**Description:** User tries to send empty message

**Steps to Execute:**
1. Click message input field
2. Leave it empty
3. Press Enter or click Send

**Expected Result:**
- ✓ Send button disabled or message not sent
- ✓ No empty message in chat
- ✓ No error shown to user

**Possible Failure Scenarios:**
- ❌ Empty message sent and stored
- ❌ Console error

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-004: Send Message with Special Characters
**Description:** User sends message with emojis and special characters

**Steps to Execute:**
1. Type message: `I love this! 😍 Can I get a 50% discount??? @admin`
2. Send message
3. Observe storage and display

**Expected Result:**
- ✓ Message sends successfully
- ✓ Emojis display correctly in chat
- ✓ Special characters preserved
- ✓ Message stored correctly in database
- ✓ Refresh maintains special characters

**Possible Failure Scenarios:**
- ❌ Emojis display as boxes/squares
- ❌ Special characters corrupted
- ❌ Message not sent with special chars
- ❌ SQL/NoSQL injection via special chars

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-005: Send Long Message (1000+ chars)
**Description:** User sends very long message

**Steps to Execute:**
1. Type long message (copy-paste 500+ word paragraph)
2. Send message
3. Observe display and storage

**Expected Result:**
- ✓ Message sends successfully
- ✓ Entire text appears without truncation in chat
- ✓ Text wraps properly (no horizontal scroll needed)
- ✓ Message stored completely in database
- ✓ Chat bubble resizes to fit text
- ✓ Scroll works smoothly with long text

**Possible Failure Scenarios:**
- ❌ Message truncated
- ❌ Text overflows outside chat bubble
- ❌ Send fails with "message too long"
- ❌ Chat becomes slow with long messages

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 3.2 Message History

#### ✅ TC-CHAT-006: Load Chat History on Login
**Description:** Previous messages appear when user logs back in

**Steps to Execute:**
1. Send several messages in chat
2. Logout from app
3. Close browser tab completely
4. Reopen app and login with same account
5. Navigate to chat

**Expected Result:**
- ✓ All previous messages load from database
- ✓ Messages appear in correct order (chronological)
- ✓ Timestamps accurate
- ✓ No duplicate messages
- ✓ Chat scroll position at bottom

**Possible Failure Scenarios:**
- ❌ Chat history not loaded
- ❌ Messages in wrong order
- ❌ Duplicate messages appear
- ❌ Very old messages missing
- ❌ Timestamps incorrect

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-007: Scroll Up to See Old Messages
**Description:** User scrolls up to see chat history

**Steps to Execute:**
1. Login to account with existing chat history
2. Scroll to bottom of chat (if not there)
3. Scroll up slowly
4. Continue scrolling to top (oldest messages)

**Expected Result:**
- ✓ Old messages load/appear as scrolling up
- ✓ Smooth scrolling (no jank)
- ✓ Load more messages if pagination implemented
- ✓ Timestamps become progressively older

**Possible Failure Scenarios:**
- ❌ Scroll is janky/laggy
- ❌ Old messages don't load
- ❌ Scroll gets stuck
- ❌ Browser crashes with large history

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-008: Clear Chat History
**Description:** User clears chat history

**Steps to Execute:**
1. Look for "Clear Chat" or "Delete History" button (usually in menu)
2. Click button
3. Confirm deletion if prompted
4. Observe chat screen

**Expected Result:**
- ✓ All messages removed from chat UI
- ✓ Chat appears empty
- ✓ Confirm dialog shows before deletion
- ✓ No messages appear after page refresh
- ✓ New messages still work

**Possible Failure Scenarios:**
- ❌ Messages not deleted from UI
- ❌ Messages still appear after refresh
- ❌ No confirmation before destructive action
- ❌ Error during deletion

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 3.3 Message Media

#### ✅ TC-CHAT-009: Send Message with Link
**Description:** User sends message containing URL

**Steps to Execute:**
1. Type message: `Check this out: https://example.com`
2. Send message
3. Observe link in chat

**Expected Result:**
- ✓ Link displays as clickable (blue, underlined or button)
- ✓ Clicking link opens in new tab (not current)
- ✓ Link preview (optional): title, description, thumbnail
- ✓ No security warnings

**Possible Failure Scenarios:**
- ❌ Link not clickable
- ❌ Link opens in same tab (loses chat)
- ❌ Malicious link warning not shown
- ❌ Link injection security issue

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-010: Message with Mention/Tags
**Description:** User tries to mention another user or use tags

**Steps to Execute:**
1. Type message: `@admin Can you help with this?`
2. Send message
3. Observe handling

**Expected Result:**
- ✓ Mention displays (highlighted or normal, depends on feature)
- ✓ Admin user notified (if feature implemented)
- ✓ Message doesn't cause injection

**Possible Failure Scenarios:**
- ❌ Mention trigger @ is escaped incorrectly
- ❌ Causes UI issues

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 3.4 Typing Indicators & Status

#### ✅ TC-CHAT-011: Typing Indicator Shows
**Description:** Typing indicator displays while chatbot processes

**Steps to Execute:**
1. Send message to chatbot
2. Wait for response (don't send another message)
3. Observe typing indicator (dots, animation, etc.)

**Expected Result:**
- ✓ Typing indicator appears while processing
- ✓ Indicator disappears when response arrives
- ✓ Smooth animation (not flickering)
- ✓ Clear that bot is "thinking"

**Possible Failure Scenarios:**
- ❌ No typing indicator
- ❌ Indicator doesn't disappear
- ❌ Appears after response (confusing)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CHAT-012: Message Read/Unread Status
**Description:** Messages show read/unread status (if feature exists)

**Steps to Execute:**
1. Send message
2. Observe message status (optional feature)

**Expected Result:**
- ✓ Single check mark: sent
- ✓ Double check mark: delivered
- ✓ Timestamp: received time
- ✓ Or no indicator (also acceptable)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 4. API RESPONSE HANDLING

### 4.1 Successful API Responses

#### ✅ TC-API-001: Successfully Fetch Product List
**Description:** API returns product data successfully

**Steps to Execute:**
1. Navigate to products/home screen
2. Wait for products to load
3. Check network tab in DevTools
4. Observe response

**Expected Result:**
- ✓ Network request: GET /products (or equivalent) returns 200 OK
- ✓ Response time: < 2 seconds
- ✓ Response contains product data (name, price, image)
- ✓ Products display on screen
- ✓ No console errors

**Possible Failure Scenarios:**
- ❌ Status code: 500 (server error)
- ❌ Response time > 5 seconds (slow)
- ❌ Empty response
- ❌ CORS error

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-002: Successfully Create Order
**Description:** POST request to create order succeeds

**Steps to Execute:**
1. Add product to cart
2. Checkout
3. Complete purchase in DevTools network tab
4. Observe POST request

**Expected Result:**
- ✓ POST request returns 201 Created or 200 OK
- ✓ Response includes order ID
- ✓ Order appears in user's order history
- ✓ Success message shown to user
- ✓ No error in console

**Possible Failure Scenarios:**
- ❌ 400 Bad Request (malformed data)
- ❌ 401 Unauthorized (session expired)
- ❌ Order not created despite success message
- ❌ Double submission creates duplicate

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 4.2 Error API Responses

#### ✅ TC-API-003: 400 Bad Request Handling
**Description:** App handles 400 Bad Request gracefully

**Steps to Execute:**
1. Open DevTools Network tab
2. Look for failed request or intentionally send bad data
3. Observe app behavior

**Expected Result:**
- ✓ User sees friendly error message (not raw error)
- ✓ Error message: "Invalid request. Please try again."
- ✓ Form highlights invalid fields (if applicable)
- ✓ No sensitive data in error

**Possible Failure Scenarios:**
- ❌ Raw error message: "TypeError: Cannot read property 'x' of undefined"
- ❌ App crashes
- ❌ No error notification shown

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-004: 401 Unauthorized Response
**Description:** App handles 401 Unauthorized (session expired)

**Steps to Execute:**
1. Simulate expired session:
   - Clear localStorage/sessionStorage with DevTools
   - Or wait for session timeout
2. Try to send message or action requiring auth
3. Observe response

**Expected Result:**
- ✓ App detects 401 response
- ✓ Redirects to login page
- ✓ Message: "Your session expired. Please login again"
- ✓ User data cleared
- ✓ Login form ready

**Possible Failure Scenarios:**
- ❌ App doesn't handle 401
- ❌ User stuck on blank screen
- ❌ 500 error instead of 401

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-005: 403 Forbidden Response
**Description:** App handles 403 Forbidden (permission denied)

**Steps to Execute:**
1. As regular user, try to access admin-only feature (if possible)
2. Observe response

**Expected Result:**
- ✓ Request returns 403 Forbidden
- ✓ User sees: "You don't have permission to access this"
- ✓ User not redirected to login (already logged in)
- ✓ No console errors

**Possible Failure Scenarios:**
- ❌ Admin feature accessible
- ❌ User redirected to login
- ❌ Generic error

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-006: 404 Not Found Response
**Description:** App handles 404 Not Found

**Steps to Execute:**
1. Try to access deleted product: `/product/nonexistent-id`
2. Observe response

**Expected Result:**
- ✓ 404 response received
- ✓ User sees: "Product not found" or similar
- ✓ Link to go back to products list
- ✓ No console errors

**Possible Failure Scenarios:**
- ❌ Blank page
- ❌ Raw 404 HTML shown
- ❌ Link to go back missing

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-007: 500 Server Error Response
**Description:** App handles 500 Internal Server Error

**Steps to Execute:**
1. Trigger server error (contact developer or check network tab)
2. Observe app behavior

**Expected Result:**
- ✓ User sees: "Something went wrong. Please try again later"
- ✓ Retry button available
- ✓ No sensitive error data in message
- ✓ Logging/reporting to admin (backend)

**Possible Failure Scenarios:**
- ❌ Stack trace shown to user
- ❌ No error message (silent failure)
- ❌ User confused

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-008: 503 Service Unavailable Response
**Description:** App handles 503 Service Unavailable (maintenance)

**Steps to Execute:**
1. Simulate server maintenance mode
2. Try any API request

**Expected Result:**
- ✓ User sees: "Service temporarily unavailable. We're working on it."
- ✓ Suggests checking back later
- ✓ No option to retry (since it won't work)

**Possible Failure Scenarios:**
- ❌ App broken with generic error

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 4.3 Network Issues

#### ✅ TC-API-009: Network Timeout Handling
**Description:** API request times out (no response)

**Steps to Execute:**
1. Slow down network: DevTools → Throttle to "Slow 3G"
2. Send message or action
3. Wait beyond typical timeout (10+ seconds)

**Expected Result:**
- ✓ Error message: "Request timed out. Please try again."
- ✓ Retry button available
- ✓ UI not frozen
- ✓ User can navigate away

**Possible Failure Scenarios:**
- ❌ App hangs indefinitely
- ❌ No error message shown
- ❌ Multiple retries sent automatically

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-010: Offline Detection
**Description:** App detects when user goes offline

**Steps to Execute:**
1. Go to DevTools → Network → Offline
2. Try to send message or make request
3. Observe notification

**Expected Result:**
- ✓ Offline indicator displays prominently
- ✓ Error message: "You're offline. Check your connection."
- ✓ UI disabled but not broken
- ✓ Actions queued or prevented

**Possible Failure Scenarios:**
- ❌ No offline notification
- ❌ App broken
- ❌ Requests sent despite being offline

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-011: CORS Error Handling
**Description:** Cross-origin request fails (CORS)

**Steps to Execute:**
1. Check DevTools Console for CORS errors
2. Or try accessing API from restricted origin
3. Observe handling

**Expected Result:**
- ✓ Request blocked at browser level
- ✓ Dev console shows CORS error (educational for debugging)
- ✓ User sees: "Unable to connect. Please try again."
- ✓ No sensitive backend info exposed

**Possible Failure Scenarios:**
- ❌ Raw CORS error shown to user
- ❌ Header mismatch not identified
- ❌ Requests still go through (CORS misconfigured)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-012: Connection Restored
**Description:** App recovers when connection restored

**Steps to Execute:**
1. Go offline (DevTools Offline)
2. Wait 10 seconds
3. Go back online
4. Try action

**Expected Result:**
- ✓ Offline indicator disappears
- ✓ API calls resume working
- ✓ Queued messages sent
- ✓ Seamless reconnection

**Possible Failure Scenarios:**
- ❌ Manual refresh required
- ❌ Offline indicator doesn't disappear
- ❌ Queued actions lost

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 4.4 Data Validation

#### ✅ TC-API-013: Invalid Response Format
**Description:** API returns unexpected data format

**Steps to Execute:**
1. Monitor network requests
2. Check if response JSON is valid
3. Intentionally corrupt response (dev testing)

**Expected Result:**
- ✓ JSON parsing doesn't crash app
- ✓ Error caught and logged
- ✓ User sees: "Data format error. Please refresh."
- ✓ App remains usable

**Possible Failure Scenarios:**
- ❌ App crashes with JSON parse error
- ❌ Partial data displayed incorrectly
- ❌ Console spam with errors

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-API-014: Missing Required Fields in Response
**Description:** API returns incomplete data

**Steps to Execute:**
1. Monitor product list response
2. Check if all products have required fields (name, price, image)
3. Verify rendering

**Expected Result:**
- ✓ App handles missing fields gracefully
- ✓ Default values shown (e.g., "N/A" for missing price)
- ✓ No blank spaces or errors
- ✓ Console warning (optional)

**Possible Failure Scenarios:**
- ❌ Missing field causes crash
- ❌ Rendering broken (malformed display)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 5. UI RESPONSIVENESS

### 5.1 Mobile Responsiveness (375px width)

#### ✅ TC-UI-MOB-001: Login Screen Mobile View
**Description:** Login screen displays correctly on mobile device (375px width)

**Steps to Execute:**
1. Open DevTools (F12) → Device Toolbar (Ctrl+Shift+M)
2. Select device: iPhone 12 (390x844) or iPhone SE (375x667)
3. Navigate to login screen
4. Scroll and interact with all elements

**Expected Result:**
- ✓ All elements visible without horizontal scroll
- ✓ Buttons fit within screen width
- ✓ Text readable (font size adequate)
- ✓ Input fields properly sized
- ✓ Form spacing looks good
- ✓ Google login button accessible

**Possible Failure Scenarios:**
- ❌ Horizontal scroll required
- ❌ Text too small (< 12px)
- ❌ Buttons cut off
- ❌ Form inputs overlapping
- ❌ Bottom button partially hidden

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-MOB-002: Chat Screen Mobile View
**Description:** Chat interface displays correctly on mobile

**Steps to Execute:**
1. Login on mobile view (375px)
2. Navigate to chat screen
3. Send several messages
4. Verify space allocation

**Expected Result:**
- ✓ Message bubbles fit width (no overflow)
- ✓ Input field at bottom, fully visible
- ✓ Send button accessible
- ✓ Chat history scrolls smoothly
- ✓ Keyboard doesn't cover input
- ✓ Messages don't overlap

**Possible Failure Scenarios:**
- ❌ Chat bubbles overflow right side
- ❌ Input field hidden by keyboard
- ❌ Scroll jumpy
- ❌ Bottom navigation overlaps chat

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-MOB-003: Product List Mobile View
**Description:** Product grid displays correctly on mobile

**Steps to Execute:**
1. View products on mobile (375px)
2. Scroll through list
3. Click on product

**Expected Result:**
- ✓ Products in single column (1 column on mobile)
- ✓ Product images sized appropriately
- ✓ Text readable
- ✓ Add to cart button fits
- ✓ Smooth scrolling
- ✓ No content cut off

**Possible Failure Scenarios:**
- ❌ Products in 2+ columns (too wide for mobile)
- ❌ Images pixelated or oversized
- ❌ Buttons not clickable
- ❌ Scroll performance poor

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-MOB-004: Product Detail Mobile View
**Description:** Product detail page displays on mobile

**Steps to Execute:**
1. Open product detail on mobile (375px)
2. Scroll through all content
3. Try Buy Now and Add to Cart

**Expected Result:**
- ✓ Product image full width
- ✓ Title and price clearly visible
- ✓ Description readable, proper line breaks
- ✓ Buy/Cart buttons both visible at bottom
- ✓ Tabs/sections scroll smoothly
- ✓ Comments section scrollable

**Possible Failure Scenarios:**
- ❌ Image cut off
- ❌ Text too small
- ❌ Buttons hidden
- ❌ Layout broken

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-MOB-005: Tablet Responsiveness (768px)
**Description:** App adapts correctly to tablet size

**Steps to Execute:**
1. DevTools → Device: iPad (768x1024)
2. Navigate through main screens
3. Verify layout

**Expected Result:**
- ✓ Elements use appropriate spacing for tablet
- ✓ 2 columns for product grid (if applicable)
- ✓ Larger buttons/touch targets
- ✓ All content accessible
- ✓ Landscape mode works

**Possible Failure Scenarios:**
- ❌ Layout same as mobile (wasted space)
- ❌ Layout same as desktop (cramped)
- ❌ Landscape breaks

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 5.2 Desktop Responsiveness (1920px width)

#### ✅ TC-UI-DESK-001: Full Desktop Layout
**Description:** App displays optimally on large desktop (1920x1080)

**Steps to Execute:**
1. Open app on desktop browser
2. Maximize window (1920x1080)
3. Verify layout

**Expected Result:**
- ✓ Content uses available space (doesn't feel cramped)
- ✓ Product grid: 3-4 columns
- ✓ Sidebar or navigation visible
- ✓ Chat interface spacious
- ✓ No excessive whitespace

**Possible Failure Scenarios:**
- ❌ Fixed max-width, poor space usage
- ❌ Layout breaks above 1920px
- ❌ Horizontal scroll appears

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-DESK-002: Ultra-Wide Desktop (2560px)
**Description:** App handles ultra-wide screens

**Steps to Execute:**
1. Resize window to 2560px width
2. Check layout

**Expected Result:**
- ✓ Content readable (max-width constraint or dynamic layout)
- ✓ No excessive stretching
- ✓ Professional appearance

**Possible Failure Scenarios:**
- ❌ Layout stretched too much
- ❌ Text too long for readability

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-DESK-003: Window Resize Smooth Transition
**Description:** App responds smoothly to window resizing

**Steps to Execute:**
1. Open app on desktop
2. Slowly drag window edge to resize (1920 → 375)
3. Observe layout changes

**Expected Result:**
- ✓ Layout transitions smoothly (no jump)
- ✓ Elements reflow naturally
- ✓ No weird scaling
- ✓ Performance smooth (60 FPS)

**Possible Failure Scenarios:**
- ❌ Layout jumps abruptly
- ❌ Lag during resize
- ❌ Elements overlap during transition

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 5.3 Touch Interactions (Mobile/Tablet)

#### ✅ TC-UI-TOUCH-001: Button Touch Target Size
**Description:** Buttons are large enough for touch (48x48px minimum)

**Steps to Execute:**
1. Switch to mobile device (375px)
2. Measure button sizes (inspection or estimation)
3. Try tapping buttons

**Expected Result:**
- ✓ All buttons minimum 48x48px
- ✓ Easy to tap without missing
- ✓ No accidental double-taps
- ✓ Hover state removed (mobile doesn't have hover)

**Possible Failure Scenarios:**
- ❌ Small buttons (< 48px)
- ❌ Hover state triggered on touch (confusing)
- ❌ Buttons too close (accidentally tap wrong one)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-TOUCH-002: Form Input Touch Navigation
**Description:** Form inputs work well with mobile keyboard

**Steps to Execute:**
1. On mobile, click email input field
2. Type email
3. Press Tab or Next key
4. Observe navigation

**Expected Result:**
- ✓ Keyboard appears
- ✓ "Next" button moves to password field
- ✓ "Done" button appears on last field
- ✓ Focus styling clear
- ✓ Keyboard doesn't obscure critical content

**Possible Failure Scenarios:**
- ❌ Keyboard hides submit button
- ❌ Tab order wrong
- ❌ Keyboard doesn't disappear when should

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-TOUCH-003: Long Press / Context Menu
**Description:** Long press doesn't break functionality (if context menu implemented)

**Steps to Execute:**
1. On mobile, long-press on text or message
2. Observe behavior

**Expected Result:**
- ✓ Either: native context menu appears (selectable)
- ✓ Or: custom context menu (copy, delete, etc.)
- ✓ App doesn't break
- ✓ No accidental actions

**Possible Failure Scenarios:**
- ❌ App breaks/freezes on long-press
- ❌ Unintended action triggered

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 5.4 Orientation Changes

#### ✅ TC-UI-ORIENT-001: Portrait to Landscape Rotation
**Description:** App adapts when device rotates portrait → landscape

**Steps to Execute:**
1. Start on mobile in portrait
2. Rotate device to landscape
3. Observe layout change

**Expected Result:**
- ✓ Layout reflow (landscape wider layout)
- ✓ Content rearranges (not truncated)
- ✓ No data loss
- ✓ Scroll position maintained (optional)
- ✓ Smooth animation

**Possible Failure Scenarios:**
- ❌ Layout broken in landscape
- ❌ Content cut off
- ❌ Need manual refresh
- ❌ Chat scrolls to top

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-UI-ORIENT-002: Landscape to Portrait Rotation
**Description:** App adapts when device rotates landscape → portrait

**Steps to Execute:**
1. Rotate device back to portrait
2. Observe layout change

**Expected Result:**
- ✓ Layout returns to portrait (single column)
- ✓ Content properly arranged
- ✓ No layout breakage

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 6. ERROR HANDLING & EDGE CASES

### 6.1 Null/Undefined Handling

#### ✅ TC-ERR-001: Missing User Profile Data
**Description:** Handle when user profile contains null/missing fields

**Steps to Execute:**
1. Login as user with incomplete profile (e.g., no profile picture)
2. Navigate to profile/dashboard
3. Observe rendering

**Expected Result:**
- ✓ App displays gracefully (no crash)
- ✓ Missing fields show default: "N/A", gray placeholder, or skip display
- ✓ Profile picture shows default avatar
- ✓ Text doesn't display "null" or "undefined"
- ✓ No console errors

**Possible Failure Scenarios:**
- ❌ App crashes
- ❌ "undefined" displayed on screen
- ❌ Layout broken
- ❌ Console error: "Cannot read property 'x' of null"

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-002: Empty Product List Response
**Description:** Handle when product API returns empty array

**Steps to Execute:**
1. Manually clear products in database (backend test)
2. Or check for products when none available
3. Observe UI

**Expected Result:**
- ✓ Empty state displayed: "No products available"
- ✓ Image/illustration of empty cart
- ✓ "Browse" or "Shop" button to explore
- ✓ No crash, no undefined errors

**Possible Failure Scenarios:**
- ❌ Blank screen (no empty state message)
- ❌ App crashes
- ❌ Confusing message

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-003: Null Chat History
**Description:** Handle when user has no chat messages yet

**Steps to Execute:**
1. Create new account
2. Navigate to chat screen
3. Observe initial state

**Expected Result:**
- ✓ Empty chat displayed: "No messages yet. Start a conversation!"
- ✓ Input field ready for typing
- ✓ No errors or undefined messages

**Possible Failure Scenarios:**
- ❌ Blank screen
- ❌ Error message shown

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 6.2 Extreme Data Cases

#### ✅ TC-ERR-004: Maximum Input Length
**Description:** User enters extremely long input (5000+ characters)

**Steps to Execute:**
1. Copy 5000 character text
2. Paste into chat input
3. Send message
4. Observe handling

**Expected Result:**
- ✓ Message sent (if no limit) or truncated with warning
- ✓ If limit: Error message: "Message exceeds maximum length (2000 chars)"
- ✓ UI doesn't break

**Possible Failure Scenarios:**
- ❌ Message not sent silently
- ❌ App freezes with large input
- ❌ Message truncated without warning

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-005: Rapid-Fire Message Sending
**Description:** User sends messages very quickly (5 messages in 1 second)

**Steps to Execute:**
1. Type quick messages
2. Spam send button
3. Observe behavior

**Expected Result:**
- ✓ All messages sent in order
- ✓ No duplicates
- ✓ No message loss
- ✓ UI handles rapid updates
- ✓ Optional: Rate limiting applied (max 1 message/sec)

**Possible Failure Scenarios:**
- ❌ Messages lost
- ❌ Duplicates sent
- ❌ App lag/stutter
- ❌ Out of order messages

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-006: Concurrent User Actions
**Description:** Multiple actions triggered simultaneously

**Steps to Execute:**
1. Click "Send" and "Clear Chat" at same time
2. Or send message while page loading
3. Observe handling

**Expected Result:**
- ✓ Actions queued or one prioritized
- ✓ No race conditions
- ✓ App doesn't crash
- ✓ Predictable outcome

**Possible Failure Scenarios:**
- ❌ Race condition causes unexpected result
- ❌ App crash
- ❌ Data corruption

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 6.3 Security Edge Cases

#### ✅ TC-ERR-007: XSS Attack via Message Input
**Description:** User attempts Cross-Site Scripting attack

**Steps to Execute:**
1. Send message: `<script>alert('XSS')</script>`
2. Observe if script executes

**Expected Result:**
- ✓ Script NOT executed (text displayed as-is)
- ✓ Message safely escaped/rendered as text
- ✓ No alert popup
- ✓ Message shows: "&lt;script&gt;alert('XSS')&lt;/script&gt;" or similar

**Possible Failure Scenarios:**
- ❌ Script executes (🚨 CRITICAL VULNERABILITY)
- ❌ Alert popup appears
- ❌ Malicious code runs

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-008: HTML Injection via Profile Name
**Description:** Attempt HTML injection in profile name

**Steps to Execute:**
1. During signup, enter name: `<img src=x onerror=alert('hi')>`
2. Complete registration
3. View profile
4. Observe rendering

**Expected Result:**
- ✓ HTML safely escaped
- ✓ Name displays literally (not rendered as HTML)
- ✓ No alert pops up
- ✓ Security maintained

**Possible Failure Scenarios:**
- ❌ HTML rendered (broken layout)
- ❌ Script executed

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-009: Authentication Token Manipulation
**Description:** User tries to modify auth token in DevTools

**Steps to Execute:**
1. Login successfully
2. Open DevTools → Application → Storage → LocalStorage
3. Find auth token (e.g., `authToken`)
4. Modify token value (change 1 character)
5. Try to perform authenticated action

**Expected Result:**
- ✓ Modified token rejected by server
- ✓ User logged out or error shown
- ✓ Cannot gain unauthorized access
- ✓ Security maintained

**Possible Failure Scenarios:**
- ❌ Modified token accepted (🚨 SECURITY ISSUE)
- ❌ User gains unauthorized access

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-010: CSRF Attack Prevention
**Description:** Verify CSRF protection in place

**Steps to Execute:**
1. Check for CSRF token in forms (inspect HTML)
2. Check HTTP headers for protection

**Expected Result:**
- ✓ CSRF token present in state-changing requests
- ✓ SameSite cookie attribute set
- ✓ Ororigin checking implemented

**Possible Failure Scenarios:**
- ❌ No CSRF protection (vulnerable)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 6.4 Database/Data Edge Cases

#### ✅ TC-ERR-011: Duplicate Product in Cart
**Description:** User adds same product to cart twice

**Steps to Execute:**
1. Find a product
2. Add to cart
3. Add same product again
4. Check cart

**Expected Result:**
- ✓ Quantity increases (not duplicate entries)
- ✓ Cart shows: Product x2
- ✓ Total price updated correctly
- ✓ Success message: "Item quantity updated"

**Possible Failure Scenarios:**
- ❌ Duplicate entries in cart
- ❌ Quantity not updated
- ❌ Price calculation wrong

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-012: Delete Non-Existent Item
**Description:** Attempt to delete item that no longer exists

**Steps to Execute:**
1. Delete cart item via X button
2. Simultaneously (or between requests), delete same item via backend
3. Observe response

**Expected Result:**
- ✓ Error handled gracefully: "Item already removed"
- ✓ UI updated to reflect deletion
- ✓ No console error
- ✓ No app crash

**Possible Failure Scenarios:**
- ❌ Confusing error
- ❌ App breaks

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-013: Order with Deleted Product
**Description:** Product is deleted after user adds it to cart but before checkout

**Steps to Execute:**
1. Add product to cart
2. Backend deletes product
3. Attempt to checkout with product in cart

**Expected Result:**
- ✓ Error message: "One or more items in your cart are no longer available"
- ✓ Cart refreshed, shows available items only
- ✓ User can remove unavailable item and retry

**Possible Failure Scenarios:**
- ❌ Order created with deleted product
- ❌ Confusing error

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 6.5 Performance Edge Cases

#### ✅ TC-ERR-014: Large Chat History Load
**Description:** User with 1000+ messages loads chat

**Steps to Execute:**
1. Create account with message history (or development database)
2. Login and navigate to chat
3. Monitor performance

**Expected Result:**
- ✓ Chat loads within 3 seconds
- ✓ Pagination or lazy loading implemented
- ✓ No freeze/white screen
- ✓ Scroll smooth
- ✓ No console errors

**Possible Failure Scenarios:**
- ❌ Page takes > 5 seconds to load
- ❌ Browser freezes
- ❌ Out of memory

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-ERR-015: Many Products on Page
**Description:** Product list with 500+ items loads

**Steps to Execute:**
1. Check product page with many products
2. Monitor performance (DevTools Performance tab)

**Expected Result:**
- ✓ Initial load < 3 seconds
- ✓ Virtual scrolling or pagination implemented
- ✓ FPS stays above 30
- ✓ Smooth scrolling

**Possible Failure Scenarios:**
- ❌ Long load time
- ❌ Jank/lag while scrolling
- ❌ Frame rate drops

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 7. BROWSER CONSOLE CHECKS

### 7.1 Console Error Types

#### ✅ TC-CONSOLE-001: No Critical JavaScript Errors
**Description:** Verify no unhandled JavaScript errors on any screen

**Steps to Execute:**
1. Open DevTools → Console tab
2. Navigate through app (all major screens)
3. Observe console for errors

**Expected Result:**
- ✓ Console clean (no red error icons)
- ✓ Only info/warning logs (optional)
- ✓ No "Uncaught Error" or "TypeError"
- ✓ CORS preflight warnings acceptable

**Possible Failure Scenarios:**
- ❌ Red error: "Cannot read property X"
- ❌ Unhandled Promise rejection
- ❌ Stack trace visible

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CONSOLE-002: No Unhandled Promise Rejections
**Description:** Verify no unhandled async errors

**Steps to Execute:**
1. Console tab → filter for "unhandled"
2. Perform actions triggering API calls
3. Check for rejection warnings

**Expected Result:**
- ✓ No "Unhandled promise rejection" messages
- ✓ All API errors caught and handled
- ✓ User sees error message (not console error)

**Possible Failure Scenarios:**
- ❌ Unhandled rejection warnings
- ❌ Silent failures

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CONSOLE-003: CORS Errors Analysis
**Description:** Verify CORS errors are expected or non-existent

**Steps to Execute:**
1. Filter console for "CORS"
2. Perform requests
3. Analyze origin/headers

**Expected Result:**
- ✓ No CORS errors (if properly configured)
- ✓ OR if errors present: preflight requests only (not blocking)
- ✓ Actual requests succeed (green status code)

**Possible Failure Scenarios:**
- ❌ Requests blocked by CORS (red errors)
- ❌ API calls fail due to CORS misconfiguration

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-CONSOLE-004: Deprecated API Warnings
**Description:** Check for deprecated browser API usage

**Steps to Execute:**
1. Console → filter for "deprecated"
2. Use app normally
3. Check for warnings

**Expected Result:**
- ✓ No or minimal deprecated API warnings
- ✓ If present: non-critical features
- ✓ Eventually to be fixed
- ✓ Performance impact minimal

**Possible Failure Scenarios:**
- ❌ Heavy use of deprecated APIs
- ❌ Critical deprecated API (causes future breaks)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 7.2 Network Tab Analysis

#### ✅ TC-NETWORK-001: No Failed Requests
**Description:** Verify all critical requests succeed

**Steps to Execute:**
1. DevTools → Network tab
2. Clear network log
3. Reload page and perform actions
4. Check for red status codes (4xx, 5xx)

**Expected Result:**
- ✓ All critical requests: 200, 201, 204 (green)
- ✓ Static assets (JS, CSS): 200 or 304 (cached)
- ✓ No 404 errors for critical resources
- ✓ Occasional 3rd party errors acceptable (analytics, etc.)

**Possible Failure Scenarios:**
- ❌ API endpoints return 500
- ❌ Images return 404
- ❌ CSS/JS resources fail

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-NETWORK-002: Request/Response Size Analysis
**Description:** Verify requests aren't excessively large

**Steps to Execute:**
1. Network tab → open a major request (e.g., product list)
2. Check "Size" column
3. Look for requests > 1MB

**Expected Result:**
- ✓ API responses: < 500KB
- ✓ JSON payloads: < 100KB
- ✓ Images: < 200KB each (compressed)
- ✓ No unusually large transfers

**Possible Failure Scenarios:**
- ❌ Large uncompressed responses
- ❌ Oversized images
- ❌ Missing gzip compression

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-NETWORK-003: Request Waterfall Analysis
**Description:** Verify requests are parallel (not sequential)

**Steps to Execute:**
1. Full page load → Network tab → Waterfall view
2. Observe request timeline

**Expected Result:**
- ✓ Parallel bars (simultaneous requests)
- ✓ No excessive blocking
- ✓ Critical path optimized
- ✓ Load time reasonable

**Possible Failure Scenarios:**
- ❌ Sequential bars (one after another)
- ❌ Long blockers (render-block resources)
- ❌ Excessive waterfall time

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 7.3 Storage Analysis

#### ✅ TC-STORAGE-001: LocalStorage Usage
**Description:** Verify localStorage contains expected data

**Steps to Execute:**
1. DevTools → Application → Storage → LocalStorage
2. Select pinky-shop-f5ad6.web.app
3. Inspect stored keys

**Expected Result:**
- ✓ Auth token/JWT stored securely
- ✓ User preferences stored (theme, language, etc.)
- ✓ Minimal sensitive data
- ✓ No passwords stored
- ✓ Total size < 5MB

**Possible Failure Scenarios:**
- ❌ Passwords in localStorage (🚨 SECURITY RISK)
- ❌ Tokens unencrypted
- ❌ Excessive data stored

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-STORAGE-002: SessionStorage Analysis
**Description:** Verify sessionStorage used appropriately

**Steps to Execute:**
1. DevTools → Storage → SessionStorage
2. Inspect data

**Expected Result:**
- ✓ Temporary session state stored (if used)
- ✓ Cleared on logout
- ✓ Minimal data

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-STORAGE-003: IndexedDB Usage (if applicable)
**Description:** Check IndexedDB for caching

**Steps to Execute:**
1. DevTools → Storage → IndexedDB (if present)
2. Inspect databases

**Expected Result:**
- ✓ Appropriate data cached (messages, products)
- ✓ Size reasonable
- ✓ Supports offline functionality

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 7.4 Performance Monitoring

#### ✅ TC-PERF-001: Lighthouse Score
**Description:** Run Lighthouse audit for overall score

**Steps to Execute:**
1. DevTools → Lighthouse tab
2. Audit scope: Mobile or Desktop
3. Run audit (takes 30-60 seconds)
4. Check scores

**Expected Result:**
- ✓ **Performance**: > 80
- ✓ **Accessibility**: > 90
- ✓ **Best Practices**: > 90
- ✓ **SEO**: > 90

**Possible Failure Scenarios:**
- ❌ Low performance score (< 50)
- ❌ Accessibility issues (< 70)
- ❌ Security warnings

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## 8. PERFORMANCE ISSUES

### 8.1 Load Time Performance

#### ✅ TC-PERF-LOAD-001: Initial Page Load Time
**Description:** Measure cold page load time

**Steps to Execute:**
1. Clear cache: DevTools → Network → Disable cache
2. Clear cookies/storage
3. Reload page
4. Measure "Finish" time

**Expected Result:**
- ✓ Total load time: < 3 seconds
- ✓ First Contentful Paint (FCP): < 1.5s
- ✓ Largest Contentful Paint (LCP): < 2.5s
- ✓ Cumulative Layout Shift (CLS): < 0.1

**Possible Failure Scenarios:**
- ❌ Load time > 5 seconds
- ❌ White blank screen
- ❌ Jank during load

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-LOAD-002: Warm Page Load (Cached)
**Description:** Measure page load with cache

**Steps to Execute:**
1. Keep cache enabled
2. Reload page (Ctrl+R or F5)
3. Measure "Finish" time

**Expected Result:**
- ✓ Load time: < 1 second
- ✓ Significant improvement from cold load

**Possible Failure Scenarios:**
- ❌ Similar time to cold load (cache not working)
- ❌ Still > 3 seconds

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-LOAD-003: Dashboard Load Time
**Description:** Measure time to interactive on dashboard

**Steps to Execute:**
1. Login
2. Measure time to dashboard "ready" (all interactive)
3. Note Time to Interactive (TTI)

**Expected Result:**
- ✓ TTI: < 2 seconds
- ✓ All buttons clickable
- ✓ API data visible

**Possible Failure Scenarios:**
- ❌ TTI > 5 seconds
- ❌ Buttons not clickable for while

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 8.2 Runtime Performance

#### ✅ TC-PERF-RUNTIME-001: Smooth Chat Scrolling
**Description:** Chat scrolling performance

**Steps to Execute:**
1. Open chat with 100+ messages
2. Scroll rapidly up/down
3. DevTools → Performance tab → Record
4. Scroll and check FPS

**Expected Result:**
- ✓ Frame rate: 60 FPS (constant)
- ✓ Smooth motion (no jank)
- ✓ No lag spikes
- ✓ GPU acceleration if available

**Possible Failure Scenarios:**
- ❌ FPS drops to 30 or below
- ❌ Janky scrolling
- ❌ Performance > 50ms per frame

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-RUNTIME-002: Message Send Responsiveness
**Description:** Message send doesn't block UI

**Steps to Execute:**
1. Performance tab recording
2. Send message
3. Stop recording
4. Analyze main thread

**Expected Result:**
- ✓ Main thread free to handle user input
- ✓ No blocking tasks > 50ms
- ✓ Immediate visual feedback (message appears)
- ✓ No input lag

**Possible Failure Scenarios:**
- ❌ Long task (> 50ms) blocks thread
- ❌ Delay before message appears
- ❌ TypingLag or stuttering

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-RUNTIME-003: Memory Leak Detection
**Description:** Check for memory leaks during extended use

**Steps to Execute:**
1. Open DevTools → Memory tab
2. Take heap snapshot (baseline)
3. Use app for 5+ minutes (send messages, navigate)
4. Take another heap snapshot
5. Compare memory usage

**Expected Result:**
- ✓ Memory stable (roughly same as baseline)
- ✓ Detached DOM nodes: < 100
- ✓ No accumulated objects
- ✓ Garbage collection working

**Possible Failure Scenarios:**
- ❌ Memory continually increases (memory leak)
- ❌ Detached DOM nodes: 1000+
- ❌ App becomes slow over time

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 8.3 Image Performance

#### ✅ TC-PERF-IMAGE-001: Image Load Time
**Description:** Product images load quickly

**Steps to Execute:**
1. Network tab
2. View product with image
3. Check "Time" and "Size" for image

**Expected Result:**
- ✓ Image size: < 200KB (compressed)
- ✓ Load time: < 1 second
- ✓ Format: WebP or modern format (if browser supports)
- ✓ Responsive images (right size for device)

**Possible Failure Scenarios:**
- ❌ Large uncompressed images
- ❌ Wrong image sizes for device
- ❌ Slow CDN or No CDN

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-IMAGE-002: Lazy Loading Images
**Description:** Images load only when needed

**Steps to Execute:**
1. Product list page
2. Product images below fold
3. DevTools Network tab
4. Scroll down
5. Observe image loading

**Expected Result:**
- ✓ Off-screen images not loaded initially
- ✓ Images load as scroll approaches (lazy load)
- ✓ Faster initial page load
- ✓ Smooth scrolling

**Possible Failure Scenarios:**
- ❌ All images load upfront (slow initial load)
- ❌ No lazy loading
- ❌ Images load but not displayed

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 8.4 Network Optimization

#### ✅ TC-PERF-NET-001: Gzip Compression
**Description:** Verify responses are gzip compressed

**Steps to Execute:**
1. Network tab → Select "Fetch/XHR"
2. Send message (or trigger API)
3. Check response headers

**Expected Result:**
- ✓ Response header "Content-Encoding: gzip"
- ✓ Size reduced significantly (70% smaller)
- ✓ Transfer speed faster

**Possible Failure Scenarios:**
- ❌ No gzip compression
- ❌ Missing Content-Encoding header

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-NET-002: Caching Headers
**Description:** Verify cache headers set correctly

**Steps to Execute:**
1. Network tab → Select static asset (JS, CSS)
2. Check Response Headers
3. Look for "Cache-Control" or "Expires"

**Expected Result:**
- ✓ Cache-Control: max-age set appropriately
- ✓ JS/CSS: 1 year (long) or hash-based
- ✓ HTML: No cache or short cache
- ✓ API responses: No cache

**Possible Failure Scenarios:**
- ❌ No cache headers
- ❌ Everything cached long-term (issues with updates)
- ❌ Everything uncached (slow pageloads)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-NET-003: Connection Persistence
**Description:** HTTP connections reused efficiently

**Steps to Execute:**
1. Network tab → connections
2. Multiple requests
3. Observe connection IDs

**Expected Result:**
- ✓ Multiple requests over same connection
- ✓ HTTP/2 or HTTP/3 in use (if available)
- ✓ Few new connections opened

**Possible Failure Scenarios:**
- ❌ New connection per request
- ❌ Connection: close headers
- ❌ HTTP/1.1 without keep-alive

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

### 8.5 Rendering Performance

#### ✅ TC-PERF-RENDER-001: No Layout Thrashing
**Description:** Multiple layout calculations don't occur unnecessarily

**Steps to Execute:**
1. Performance tab → Record
2. Perform action (e.g., send message)
3. Check "Layout" events in timeline

**Expected Result:**
- ✓ Single layout per render cycle (optimal)
- ✓ No repeated layout calculations
- ✓ < 16ms per frame

**Possible Failure Scenarios:**
- ❌ Multiple layouts per frame (thrashing)
- ❌ Long layout time (> 50ms)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

#### ✅ TC-PERF-RENDER-002: Optimized Animations
**Description:** Animations smooth and efficient

**Steps to Execute:**
1. Find animation (e.g., loading spinner, transition)
2. Performance tab → Record animation
3. Check for "jank"

**Expected Result:**
- ✓ Constant 60 FPS during animation
- ✓ No frame drops (showing "frames 60, 45, 30")
- ✓ Smooth motion

**Possible Failure Scenarios:**
- ❌ Jank/stuttering animation
- ❌ Frame rate drops
- ❌ Animation uses main thread (blocks interaction)

**Pass/Fail:** ☐ PASS / ☐ FAIL

---

---

## SUMMARY TABLE

| Feature | Category | Test Cases | Pass | Fail | Notes |
|---------|----------|-----------|------|------|-------|
| **Authentication** | Email/Password | 6 | ☐ | ☐ | |
| | Signup | 4 | ☐ | ☐ | |
| | Google Sign-In | 4 | ☐ | ☐ | ⚠️ Domain authorization required |
| | Session Management | 3 | ☐ | ☐ | |
| **Forgot Password** | Password Reset | 4 | ☐ | ☐ | |
| | Reset Link Validation | 3 | ☐ | ☐ | |
| | New Password | 3 | ☐ | ☐ | |
| **Chatbot Messaging** | Basic Messaging | 5 | ☐ | ☐ | |
| | Chat History | 3 | ☐ | ☐ | |
| | Message Media | 2 | ☐ | ☐ | |
| | Typing Indicators | 2 | ☐ | ☐ | |
| **API Response Handling** | Successful Responses | 2 | ☐ | ☐ | |
| | Error Responses | 8 | ☐ | ☐ | |
| | Network Issues | 4 | ☐ | ☐ | |
| | Data Validation | 2 | ☐ | ☐ | |
| **UI Responsiveness** | Mobile (375px) | 5 | ☐ | ☐ | |
| | Tablet (768px) | 1 | ☐ | ☐ | |
| | Desktop (1920px+) | 3 | ☐ | ☐ | |
| | Touch Interactions | 3 | ☐ | ☐ | |
| | Orientation Changes | 2 | ☐ | ☐ | |
| **Error Handling** | Null/Undefined | 3 | ☐ | ☐ | |
| | Extreme Data | 3 | ☐ | ☐ | |
| | Security Edge Cases | 4 | ☐ | ☐ | 🔒 CRITICAL |
| | Database Edge Cases | 3 | ☐ | ☐ | |
| | Performance Edge Cases | 2 | ☐ | ☐ | |
| **Browser Console** | JavaScript Errors | 4 | ☐ | ☐ | |
| | Network Analysis | 3 | ☐ | ☐ | |
| | Storage Analysis | 3 | ☐ | ☐ | |
| | Performance Monitoring | 1 | ☐ | ☐ | |
| **Performance** | Load Times | 3 | ☐ | ☐ | |
| | Runtime Performance | 3 | ☐ | ☐ | |
| | Image Performance | 2 | ☐ | ☐ | |
| | Network Optimization | 3 | ☐ | ☐ | |
| | Rendering Performance | 2 | ☐ | ☐ | |
| | **TOTAL** | **~150 test cases** | **☐** | **☐** | |

---

## PRIORITY RECOMMENDATIONS

### 🔴 CRITICAL (Must Fix Before Production)
- ✅ TC-API-004: 401 Unauthorized handling
- ✅ TC-AUTH-011: Google domain authorization
- ✅ TC-ERR-007: XSS vulnerability testing
- ✅ TC-ERR-009: Auth token manipulation protection
- ✅ TC-PERF-LOAD-001: Initial load time < 3s

### 🟠 HIGH (Before Beta Release)
- ✅ TC-PERF-RUNTIME-003: Memory leak detection
- ✅ TC-UI-MOB-001 through 004: Mobile responsiveness
- ✅ TC-ERR-001 through 003: Null handling
- ✅ TC-NETWORK-001: Request failures

### 🟡 MEDIUM (Before GA)
- ✅ All error handling tests
- ✅ Performance optimization
- ✅ Browser compatibility

---

## SIGN-OFF

**QA Tester Name:** _________________  
**Date:** _________________  
**Status:** ☐ PASS / ☐ FAIL / ☐ PARTIAL  
**Blockers:** _________________  
**Notes:** _________________
