module ApplicationHelper
  def page_title
    content_for(:title || 'Todos')
  end

  def is_signed_in?
    !Current.user.nil? 
  end

  def is_guest_user?
    !Current.user.otp_user?
  end

end
