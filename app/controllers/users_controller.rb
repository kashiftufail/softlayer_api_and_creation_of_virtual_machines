require 'net/http'
require 'rubygems'
require 'softlayer_api'
require 'pp'
require 'net/https'
require 'uri'

#http://sldn.softlayer.com/article/SoftLayer-API-Overview       For More Methods take a look here
#http://sldn.softlayer.com/reference/services/SoftLayer_Virtual_Guest/         For More Methods Relating to Virtual Guest take a look at this URL. Like(Reboot machine ,get graph ,get memory and cpu status and many more...)


class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = current_admin.users
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
  end

  def disable_user
    @user = User.find_by_id(params[:id])

    unless @user.blank?
      @user.update_attributes(:is_activated => false)
      account_guest = SoftLayer::Service.new("SoftLayer_Virtual_Guest")
      account_guest.object_with_id(@user.server_uniq_id).powerOff unless  @user.blank?
    end
    @users = current_admin.users
    render :partial => "users/user_list", :layout => false
  end

  def enable_user
    @user = User.find_by_id(params[:id])
    unless @user.blank?
      @user.update_attributes(:is_activated => true)
      account_guest = SoftLayer::Service.new("SoftLayer_Virtual_Guest")
      account_guest.object_with_id(@user.server_uniq_id).powerOn unless  @user.blank?
    end
    @users = current_admin.users
    render :partial => "users/user_list", :layout => false
  end

  # POST /users
  # POST /users.json
  def create
    $SL_API_USERNAME = 'user_name'
    $SL_API_KEY = "your_key"
    softlayer_product_package = SoftLayer::Service.new("SoftLayer_Product_Package")
    softLayer_product_item_price = SoftLayer::Service.new("SoftLayer_Product_Item_Price")
    softLayer_product_order = SoftLayer::Service.new("SoftLayer_Product_Order")
    account_service = SoftLayer::Service.new("SoftLayer_Account")
    @user = User.new(params[:user])
    @user.admin_id = current_admin.id
    if @user.save

      $product_order = {
          'complexType' => 'SoftLayer_Container_Product_Order_Virtual_Guest',

          'quantity' => 1,


          'virtualGuests' => [
              {
                  'hostname' => "RockStar",
                  'domain' => 'star.net'
              }
          ],


          'location' => nil,
          'packageId' => nil,
          'prices' => nil,
          'useHourlyPricing' => true,
      }

      $product_order["packageId"] = 46
      $virtual_guest_package = softlayer_product_package.object_with_id(46)

      $product_order["location"] = 138124

      $product_order["prices"] = [
          {"id" => 1641}, #   1641 -- 2 x 2.0 GHz Cores [Computing Instance]
          {"id" => 1645}, #   1647 -- 2 GB [Ram]
          {"id" => 905}, #   905 -- Reboot / Remote Console [Remote Management]
          {"id" => 272}, #   10 Mbps Public &amp; Private Networks
          {"id" => 1800}, #   1800 0 GB Bandwidth
          {"id" => 21}, #   21 -- 1 IP Address [Primary IP Addresses]
          {"id" => 13899}, #   13899 -- 100 GB (Local)  [First Disk]
          {"id" => 1685}, #   1685 -- CentOS 5 - Minimal Install (64 bit)  [Operating System]
          {"id" => 55}, #   55 -- Host Ping [Monitoring]
          {"id" => 57}, #   57 -- Email and Ticket [Notification]
          {"id" => 58}, #   58 -- Automated Notification [Response]
          {"id" => 420}, #   420 -- Unlimited SSL VPN Users &amp; 1 PPTP VPN User per account [VPN Management - Private Network]
          {"id" => 418} #   418 -- Nessus Vulnerability Assessment &amp; Reporting [Vulnerability Assessments &amp; Management]
      ]

      begin

        result = softLayer_product_order.verifyOrder($product_order)
        if result
          result2 = softLayer_product_order.placeOrder($product_order)
        end
        all_guest = account_service.getVirtualGuests
        all_guest.each do |rec|
          @id = rec["id"] if rec["primaryIpAddress"].blank?
        end
        @user.update_attributes(:server_uniq_id => @id) unless @id.blank?

        @user.seed_ip(@user) #handle seed_ip method with delayed job who run it after 15 minutes.Because api assign ip address to server after at least 15 minutes

      rescue => error_reason
        puts "The order could not be verified by the server #{error_reason}"
      end

      redirect_to '/users', :notice => 'User was successfully created.'
    else
      render :action => "new"
    end
  end


# DELETE /users/1
# DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      account_guest = SoftLayer::Service.new("SoftLayer_Virtual_Guest")
      account_service4 = SoftLayer::Service.new("SoftLayer_Billing_Item")
      object_mask = {
          "billingItem" => ""
      }
      obj_msk = account_guest.object_with_id(@user.server_uniq_id).object_mask(object_mask).getObject unless @user.blank?
      account_service4.object_with_id(obj_msk["billingItem"]["id"]).cancelService unless obj_msk.blank?
    end
    redirect_to users_url
  end

end
