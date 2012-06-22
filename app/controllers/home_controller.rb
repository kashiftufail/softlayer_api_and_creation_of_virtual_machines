class HomeController < ApplicationController
  def index
    @users = current_admin.users
  end
end
