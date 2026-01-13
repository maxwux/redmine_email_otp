module RedmineEmailOtp
  module Patches
    module AccountControllerPatch
      def self.prepended(base)
        # 在 login 執行之前，先執行我們的檢查
        base.prepend_before_action :check_email_otp, only: [:login]
      end

      def check_email_otp
        # 只處理 POST 登入請求
        return unless request.post? && params[:username].present? && params[:password].present?

        # 嘗試驗證密碼
        user = User.try_to_login(params[:username], params[:password])
        
        # 密碼錯誤或帳號停用，直接 return，讓 Redmine 原生邏輯處理報錯
        return if user.nil? || !user.active?

        # 【Email OTP 檢查】
        if user.respond_to?(:enable_otp) && user.enable_otp?
          Rails.logger.info "🔥 [OTP] 使用者 #{user.login} 需要 Email 2FA"
          
          code = rand(100000..999999).to_s
          user.update_columns(otp_code: code, otp_sent_at: Time.now)
          
          begin
            OtpMailer.send_otp(user).deliver_now
          rescue => e
            Rails.logger.error "🔥 [OTP Error] 寄信失敗: #{e.message}"
          end
          
          session[:otp_user_id] = user.id
          
          # 轉址並停止後續 Action
          redirect_to otp_verify_path
        else
          # 【無 Email OTP】
          # 什麼都不做，讓流程繼續往下走
          # Redmine 會執行 login action，並自動處理原生 App 2FA
          Rails.logger.info "🔥 [OTP] 使用者 #{user.login} 放行 (交由 Redmine 處理)"
        end
      end
    end
  end
end
