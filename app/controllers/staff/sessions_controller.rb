class Staff::SessionsController < Staff::Base
  def new
    if current_staff_member
      redirent_to :staff_root
    else
      @form = Staff::LoginForm.new
      render action: "new"
    end
  end

  def create
    @form = Staff::LoginForm.new(params[:staff_login_form])
    if @form.email.present?
      staff_member =
        StaffMember.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    if Staff::Authenticator.new(staff_member).authenticate(@form.password)
      if staff_member.suspended?
        flash.now.alert = "アカウントが停止されています。"
        render action: "new"
      else
        flash.notice = "ログインしました。"
        redirect_to :staff_root
        session[:staff_member_id] = staff_member.id
      end
    else
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render action: "new"
    end
  end

  def destroy
    session.delete(:staff_member_id)
    flash.notice = "ログアウトしました。"
    redirect_to :staff_root
  end
end
