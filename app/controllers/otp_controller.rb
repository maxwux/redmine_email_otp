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

    # 驗證 OTP 代碼與時間 (10分鐘內有效)
    if params[:otp_code].to_s.strip == user.otp_code.to_s.strip && user.otp_sent_at > 10.minutes.ago
      # ==================
      # 🎉 驗證成功
      # ==================
      user.update_columns(otp_code: nil)
      session[:otp_user_id] = nil
      successful_authentication(user)
    else
      # =============================================================
      # 🔒【Sagiri 安全補丁】OTP 驗證失敗
      # =============================================================
      # 我們在這裡埋入一個 Log，格式必須配合 Fail2Ban 的正則表達式
      # 這樣 Fail2Ban 才能抓到 "SECURITY_OTP_FAILURE" 這個關鍵字
      
      Rails.logger.warn "SECURITY_OTP_FAILURE: Failed OTP attempt for user '#{user.login}' from IP: #{request.remote_ip}"

      flash[:error] = "驗證碼錯誤或已過期"
      render :verify
    end
  end
end
