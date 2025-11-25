# Redmine Email OTP Plugin

This is a custom Two-Factor Authentication (2FA) plugin for Redmine 5.x.

## Features

* **Hybrid 2FA Support:**
    * **Email OTP:** Sends a 6-digit code via email for users with "Enable Email OTP" checked.
    * **Native 2FA:** Fully compatible with Redmine's native Google Authenticator (TOTP) for other users.
* **Non-intrusive:** Uses `prepend_before_action` to intercept login without breaking core functionalities.
* **User Friendly:** Simple configuration in the user administration page.

## Installation

1.  Clone this repo into `plugins/redmine_email_otp`.
2.  Run `bundle install`.
3.  Run `RAILS_ENV=production bundle exec rake redmine:plugins:migrate`.
4.  Restart Redmine.

## Configuration ⚠️

**Important:** This plugin relies on Redmine's built-in email delivery system. You **must** configure your SMTP settings in `config/configuration.yml` for the OTP emails to be sent.

1.  Copy the sample configuration file:
    ```bash
    cp config/configuration.yml.example config/configuration.yml
    ```

2.  Edit `config/configuration.yml` and add your SMTP settings. Here is an example using Gmail:

    ```yaml
    production:
      email_delivery:
        delivery_method: :smtp
        smtp_settings:
          enable_starttls_auto: true
          address: "smtp.gmail.com"
          port: 587
          domain: "smtp.gmail.com"
          authentication: :plain
          user_name: "your_email@gmail.com"
          password: "your_app_password"
    ```

3.  **Restart Redmine** after modifying the configuration file.

## Usage

1.  Go to **Administration > Users**.
2.  Edit a user and check the **"Enable Email 2FA"** box.
3.  That user will now receive an OTP via email upon login.

## Author

Developed by Max & Sagiri.
