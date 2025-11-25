class AddEmailOtpFields < ActiveRecord::Migration[6.1]
  def change
    # 1. 新增 enable_otp 開關 (預設 false)
    unless column_exists?(:users, :enable_otp)
      add_column :users, :enable_otp, :boolean, default: false
    end

    # 2. 新增 otp_code (存驗證碼)
    unless column_exists?(:users, :otp_code)
      add_column :users, :otp_code, :string
    end

    # 3. 新增 otp_sent_at (存發送時間)
    unless column_exists?(:users, :otp_sent_at)
      add_column :users, :otp_sent_at, :datetime
    end
  end
end
