class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

   before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters

      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation, :name) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation, :current_password, :name) }
    end

  protect_from_forgery with: :exception

  before_filter :categories, :brands, :cart_items


  def categories
  	@categories = Category.all
  end

  def brands
  	@brands = Product.pluck(:brand).sort.uniq!
  end

  def cart_items
    if user_signed_in?
      @cart_items = LineItem.where(customer_key: current_user.id.to_s)
    else
      @cart_items = LineItem.where(customer_key: remote_ip)
    end
  end

  def remote_ip
    if request.remote_ip == '127.0.0.1'
    #hard coded remote address  
      "#{ENV['my_url']}"
    else
      request.remote_ip
    end 
  end 


  
end
