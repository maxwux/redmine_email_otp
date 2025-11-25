module RedmineEmailOtp
  module Patches
    module AccountControllerPatch
      def self.prepended(base)
        # Intercept login action before it executes
        base.prepend_before_action :check_email_otp, only: [:login]
      end

      def check_email_otp
        # Only process POST login requests with username and password
        return unless request.post? && params[:username].present? && params[:password].present?

        # Validate credentials (without affecting standard Redmine flow)
        user = User.try_to_login(params[:username], params[:password])
        
        # If login failed or user inactive, return to let Redmine handle the error
        return if user.nil? || !user.active?

        # --- Email OTP Check ---
        if user.respond_to?(:enable_otp) && user.enable_otp?
          Rails.logger.info "[OTP] User #{user.login} requires Email 2FA. Intercepting..."
          
          # Generate and save code
          code = rand(100000..999999).to_s
          user.update_columns(otp_code: code, otp_sent_at: Time.now)
          
          # Send Email
          begin
            OtpMailer.send_otp(user).deliver_now
          rescue => e
            Rails.logger.error "[OTP Error] Failed to send email: #{e.message}"
            flash[:error] = "Failed to send verification code. Please contact administrator."
          end
          
          # Store user ID in session for verification
          session[:otp_user_id] = user.id
          
          # Redirect to OTP verification page and stop further processing
          redirect_to otp_verify_path
        else
          # --- No Email OTP ---
          # Let the request proceed to standard Redmine login
          # Redmine will handle Native 2FA (Google Auth) or simple login
          Rails.logger.info "[OTP] User #{user.login} does not use Email 2FA. Proceeding to standard flow."
        end
      end
    end
  end
end
