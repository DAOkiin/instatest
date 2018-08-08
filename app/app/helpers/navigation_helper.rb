module NavigationHelper
  def current_user_nav_partial_path
    if user_signed_in?
      'layouts/navigation/signed_in_links'
    else
      'layouts/navigation/non_signed_in_links'
    end
  end
end
