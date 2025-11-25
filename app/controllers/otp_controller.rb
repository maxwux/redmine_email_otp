class OtpController < AccountController
  # Skip login check for verification pages
  skip_before_action :check_if_login_required, only: [:verify, :check], raise: false

  def verify
    # Redirect to login if session is missing
    if session[:otp_user_id].blank?
      redirect_to signin_path
    end
  end

  def check
    user = User.find_by(id: session[:otp_user_id])
    if user.nil?
      redirect_to signin_path
      return
    end

    # Validate code and expiration (10 minutes)
    if params[:otp_code].to_s.strip == user.otp_code.to_s.strip && user.otp_sent_at > 10.minutes.ago
      # Success: Clear code and login
      user.update_columns(otp_code: nil)
      session[:otp_user_id] = nil
      successful_authentication(user)
    else
      flash[:error] = "Invalid verification code or code expired."
      render :verify
    end
  end
end
