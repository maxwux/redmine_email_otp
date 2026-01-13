class OtpMailer < Mailer
  def send_otp(user)
    @user = user
    @otp_code = user.otp_code
    mail(to: @user.mail, subject: "[Redmine] 登入驗證碼：#{@otp_code}")
  end
end
