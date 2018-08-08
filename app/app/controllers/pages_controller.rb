class PagesController < ApplicationController
  helper :pages
  before_action :authenticate_user!, except: [:home]
  rescue_from Instagram::BadRequest, with: :bad_token

  def home
    collect_data if user_signed_in? && current_user.token.present?
  end

  def auth_token
    responce = IgService.request_token_with(params[:code])
    if current_user.update_attributes(token: responce['access_token'])
      flash[:notice] = 'Токен доступа обновлен'
    end

    redirect_to root_path
  end

  private

  def collect_data
    igservice = IgService.new(access_token: current_user.token)
    @user_data = IgService.user_account_data(current_user.token)['data']
    @recent_media = igservice.user_media.map
                             .sort_by { |i| i['likes']['count'] }
                             .reverse[0..3]
  end

  def bad_token
    flash[:notice] = 'Отказано в доступе'
    current_user.update_attributes!(token: nil)
    redirect_to root_path
  end
end
