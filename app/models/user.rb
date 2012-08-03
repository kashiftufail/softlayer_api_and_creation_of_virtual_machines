class User < ActiveRecord::Base
  belongs_to :admin


  def seed_ip(user)
    # your logic to insert ip address for server in user table
  end

end
