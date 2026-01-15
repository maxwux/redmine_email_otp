module RedmineEmailOtp
  module Patches
    module UsersControllerPatch
      def index
        # 如果點選了狀態，但參數不是 Redmine 原生的格式 (f[], op[], v[])
        # 我們就幫它「變身」成原生格式
        if params[:status].present? && params[:f].blank?
          params[:set_filter] = "1"
          params[:f] = ["status"]
          params[:op] = { "status" => "=" }
          params[:v] = { "status" => [params[:status].to_s] }
        end

        # 處理名稱搜尋，一樣變身成原生的 login 模糊搜尋 (~)
        if params[:name].present? && params[:f].present? && !params[:f].include?("login")
          params[:f] << "login"
          params[:op]["login"] = "~"
          params[:v]["login"] = [params[:name]]
        end

        # 讓 Redmine 原生的邏輯去接手，這樣就不會報 page 錯誤，也能正常分頁了！
        super
      end
    end
  end
end
