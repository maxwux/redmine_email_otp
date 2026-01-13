Redmine::Plugin.register :redmine_email_otp do
  name 'Redmine Email OTP'
  author 'Max & Sagiri'
  description 'Email 2FA (Production Ready)'
  version '1.1.0'
  url 'https://github.com/example/redmine_email_otp'
end

Rails.configuration.after_initialize do
  require_dependency 'user'
  User.safe_attributes 'enable_otp'
  
  require_dependency 'account_controller'
  require_relative 'lib/redmine_email_otp/patches/account_controller_patch'
  
  unless AccountController.included_modules.include?(RedmineEmailOtp::Patches::AccountControllerPatch)
    AccountController.send(:prepend, RedmineEmailOtp::Patches::AccountControllerPatch)
  end
  
  require_relative 'lib/redmine_email_otp/hooks/view_users_form_hook'
  puts "🔥 [OTP] 插件載入完成 (v1.1.0)"
end
