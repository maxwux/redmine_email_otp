Redmine::Plugin.register :redmine_email_otp do
  name 'Redmine Email OTP'
  author 'Max & Sagiri'
  description 'Two-Factor Authentication (2FA) via Email for Redmine'
  version '1.0.0'
  url 'https://github.com/your_username/redmine_email_otp'
end

Rails.configuration.after_initialize do
  # Load User model and safe attributes
  require_dependency 'user'
  User.safe_attributes 'enable_otp'
  
  # Load AccountController and apply patch
  require_dependency 'account_controller'
  require_relative 'lib/redmine_email_otp/patches/account_controller_patch'
  
  unless AccountController.included_modules.include?(RedmineEmailOtp::Patches::AccountControllerPatch)
    AccountController.send(:prepend, RedmineEmailOtp::Patches::AccountControllerPatch)
  end
  
  # Load Hooks
  require_relative 'lib/redmine_email_otp/hooks/view_users_form_hook'
  
  Rails.logger.info "[OTP] Plugin loaded successfully."
end
