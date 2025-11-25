class OtpController < AccountController
  skip_before_action :check_if_login_required, only: [:verify, :check], raise: false

  def verify
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

    if params[:otp_code].to_s.strip == user.otp_code.to_s.strip && user.otp_sent_at > 10.minutes.ago
      user.update_columns(otp_code: nil)
      session[:otp_user_id] = nil
      successful_authentication(user)
    else
      flash[:error] = "驗證碼錯誤或已過期"
      render :verify
    end
  end
end
