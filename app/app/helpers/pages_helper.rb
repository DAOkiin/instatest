module PagesHelper
  def user_views_helper
    if user_signed_in?
      'layouts/home/signed_view'
    else
      'layouts/home/unsigned_view'
    end
  end

  def instagram_account_helper
    if current_user.token.nil?
      'layouts/instagram/auth'
    else
      'layouts/instagram/user_data'
    end
  end

  def instagram_auth_path
    # scope = 'likes relationships basic public_content follower_list comments'
    scope = 'basic public_content follower_list'
    Instagram.authorize_url(redirect_uri: ENV.fetch('CALLBACK_URL'),
                            scope: scope)
  end
end
