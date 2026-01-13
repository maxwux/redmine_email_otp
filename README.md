# Redmine Email OTP Plugin

This is a custom Two-Factor Authentication (2FA) plugin for Redmine 5.x.

## Features

* **Hybrid 2FA Support:**
    * **Email OTP:** Sends a 6-digit code via email for users with "Enable Email OTP" checked.
    * **Native 2FA:** Fully compatible with Redmine's native Google Authenticator (TOTP) for other users.
* **Security & Logging:**
    * **Fail2Ban Ready:** Logs specific security events (`SECURITY_OTP_FAILURE`) including Client IP when an OTP check fails. This allows integration with intrusion prevention software like Fail2Ban.
* **Non-intrusive:** Intercepts login flow without breaking core functionalities.
* **User Friendly:** Simple configuration in the user administration page.

## Installation

1.  Clone this repo into `plugins/redmine_email_otp`.
2.  Run `bundle install`.
3.  Run `RAILS_ENV=production bundle exec rake redmine:plugins:migrate`.
4.  Restart Redmine.

## Usage

1.  Go to **Administration > Users**.
2.  Edit a user and check the **"Enable Email 2FA"** box.
3.  That user will now receive an OTP via email upon login.

## Security & Fail2Ban Configuration

This plugin logs failed attempts to `production.log` with the tag `SECURITY_OTP_FAILURE`. You can use **Fail2Ban** to block IP addresses that repeatedly fail OTP verification.

### 1. Filter Definition
Create or edit your filter file (e.g., `/etc/fail2ban/filter.d/redmine.conf`):

```ini
[Definition]
failregex = ^.*Failed login for .* from <HOST>.*$
            ^.*SECURITY_OTP_FAILURE: Failed OTP attempt for user .* from IP: <HOST>$
ignoreregex =
```

### 2. Jail Configuration

Add the jail to your jail.local configuration:
```ini
[redmine]
enabled = true
filter = redmine
logpath = /usr/src/redmine/log/production.log
maxretry = 3
findtime = 600
bantime = 3600
```

Author

Developed by Max
