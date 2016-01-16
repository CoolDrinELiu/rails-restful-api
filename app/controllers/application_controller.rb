require "open-uri"
require 'json'
require_relative 'errors'

class ApplicationController < ActionController::Base
  protect_from_forgery		# 

  include SessionsHelper	# Helper is automatically included in View, but not not automatically included in Controllder.
  #helper :layout # include all layout helpers for all views globally
  helper_method :basic_auth_api, :current_admin, :current_vender,
                :require_admin, :require_seller_admin, :require_buyer, :require_consumer_contact,
                :require_customer, :require_vender_admin, :require_general, :require_seller
                :mobile_device?

  before_filter :set_locale, :check_for_mobile
  after_filter :set_access_control_headers


  ###### Filter

  def set_locale
    preferred_locales = request.headers['HTTP_ACCEPT_LANGUAGE'].split(',').map { |l| l.split(';').first.downcase } rescue nil
    if preferred_locales && preferred_locales.first
      if preferred_locales.first[0,2] == "zh"
        preferred_locales.replace(["zh-cn"])
      else
        preferred_locales.replace(["en"])
      end
    end

    available_locales = I18n.available_locales.map{|l| l.to_s.downcase.to_sym }

    I18n.locale = begin
      locale = preferred_locales.select { |l| available_locales.include?(l.to_sym) } rescue nil
      locale = locale == nil || locale.empty? ? I18n.default_locale : locale.first
      if params[:locale] && available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale].to_sym
      elsif I18n.locale == nil
        I18n.locale = locale.to_sym
      else
        #I18n.locale
        I18n.locale = locale.to_sym
      end
      I18n.locale
    rescue
      # if something happens (like a locale file renamed!?) go back to the default
      I18n.default_locale
    end
  end

  # check for mobile
  def prepare_for_mobile
    prepend_view_path Rails.root + 'app' + 'views_mobile'
  end
  def mobile_device?
    agent = request.headers["HTTP_USER_AGENT"].downcase
    (agent =~ /mobile|webos/) && (agent !~ /ipad/)
  end
  def check_for_mobile
    prepare_for_mobile if mobile_device?
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end


  ###### Helper Method

  def basic_auth_api
    authenticate_or_request_with_http_basic("API") do |phone, password|
      @current_user = nil
      if user = User.authenticate_with_phone(phone, password)
        @current_user = user
        true
      else
        sleep 2
        false
      end
    end
  end

  private

  def admin?
    current_user && current_user.admin?
  end

  def seller_admin?
    current_user && current_user.seller_admin?
  end

  def buyer?
    current_user && current_user.buyer?
  end

  def general?
    current_user && current_user.general?
  end

  def consumer_contact?
    current_user && current_user.consumer_contact?
  end

  def customer?
    current_user && current_user.customer?
  end

  def vender_admin?
    current_user && current_user.vender_admin?
  end

  def require_admin
    unless current_user && current_user.admin?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_admin = current_user
      return true
    end
  end

  def require_seller_admin
    unless current_user && current_user.seller_admin?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_seller_admin = current_user
      return true
    end
  end

  def require_seller
    unless current_user && current_user.seller?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_seller = current_user
      return true
    end
  end

  def require_buyer
    unless current_user && current_user.buyer?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_buyer = current_user
      return true
    end
  end

  def require_general
    unless current_user && current_user.general?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_general = current_user
      return true
    end
  end

  def require_consumer_contact
    unless current_user && current_user.consumer_contact?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_consumer = Consumer.find_by_contact_id(current_user.id)
      return true
    end
  end

  def require_customer
    unless current_user && current_user.customer?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_customer = current_user
      return true
    end
  end

  def require_vender_admin
    unless current_user && current_user.vender_admin?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to root_path
      return false
    else
      @current_vender = Vender.find_by_admin_id(current_user.id)
      return true
    end
  end

  def current_admin
    @current_admin if defined?(@current_admin)
  end

  def current_seller_admin
    @current_seller_admin if defined?(@current_seller_admin)
  end

  def current_seller
    @current_seller if defined?(@current_seller)
  end

  def current_buyer
    @current_buyer if defined?(@current_buyer)
  end

  def current_general
    @current_general if defined?(@current_general)
  end

  def current_consumer
    @current_consumer if defined?(@current_consumer)
  end

  def current_customer
    @current_customer if defined?(@current_customer)
  end

  def current_vender
    @current_vender if defined?(@current_vender)
  end

  ######

  def store_location
    session[:return_to] = request.url
  end

  def track_api(tracking_data)
    sessions = Session.where(:user_id => tracking_data["user_id"], :client_uuid => tracking_data["client_uuid"], :active => true).order("updated_at ASC")
    if sessions.length > 1
      sessions.update_all(:active => false)
      last_session = sessions.last
      last_session.update_attribute(:active, true)
      last_session.touch
    elsif sessions.length == 1
      sessions.last.touch
    else
      session = Session.new(:user_id => tracking_data["user_id"], :client_uuid => tracking_data["client_uuid"], :active => true)
      session.save
    end

    if tracking_data["lat"] && tracking_data["lng"] && tracking_data["lat"].strip() != "" && tracking_data["lng"].strip() != ""
      api_tracking = ApiTracking.new(:user_id => tracking_data["user_id"], :lat => tracking_data["lat"], :lng => tracking_data["lng"])
      api_tracking.save
    end
  end

  def stop_api_session(user_id, client_uuid)
    sessions = Session.where(:user_id => user_id, :client_uuid => client_uuid, :active => true).order("updated_at ASC")
    if sessions.length > 0
      sessions.each{|session|
        session.update_attribute(:active, false)
        session.touch
      }
    end
  end

  def api_render_error(controller, error_message = {}, status = 401)
    controller.status = status
    xmlStr = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.errors {
        xml.error error_message[:msg]
        xml.code error_message[:code]
      }
    end
    controller.response_body = Hash.from_xml(xmlStr.to_xml).to_json
  end

  def api_render_result(body = {}, error = {})
    retObj = {
        :body => body,
        :error => error
    }
    respond_with JSON::dump(retObj), :status => :ok, :location => "api"
    #respond_with JSON::dump(body), :status => :ok, :location => "api"
  end

  def check_signature(timestamp, nonce, signature)
    token = "#{WEIXINTOKEN}"

    strList = []
    strList.push(token) if token
    strList.push(timestamp) if timestamp
    strList.push(nonce) if nonce
    strResult = Digest::SHA1.hexdigest(strList.sort.join)

    if strResult == signature
      true
    else
      false
    end
  end

  def get_access_token
    if Rails.cache.read("access_token").nil?
      res = URI.parse("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{WEIXINAPPID}&secret=#{WEIXINAPPSECRET}").read
      @access_token = JSON.parse(res)["access_token"]
      Rails.cache.write("access_token", @access_token, expires_in: 5.minutes)
      @access_token
    else
      @access_token = Rails.cache.read("access_token")
    end
  end

end
