module RedmineEmailOtp
  module Hooks
    class ViewUsersFormHook < Redmine::Hook::ViewListener
      def view_users_form(context={})
        f = context[:form]
        # Use l(:label_...) to support internalization
        checkbox = f.check_box(:enable_otp, label: l(:label_enable_otp_verification))
        return "<p>#{checkbox}</p>".html_safe
      end
    end
  end
end
