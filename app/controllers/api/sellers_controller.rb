class Api::SellersController < ApplicationController
  before_filter :basic_auth_api
  respond_to :json

  def get_trans_by_time
    unless current_user.seller?
      api_render_result(nil, E_USER_ROLE_ERROR)
      return
    end
    unless  params[:client_uuid] && params[:start_time] && params[:end_time] && current_user
      api_render_result(nil, E_API_PARAMETER_ERROR)
      return
    end
    track_api({"user_id" => current_user.id, "client_uuid" => "#{params[:client_uuid]}", "lat" => "#{params[:latitude]}", "lng" => "#{params[:longitude]}"}) if current_user

    start_time = DateTime.strptime(params[:start_time],"%Y-%m-%d %H:%M:%S") - 1
    end_time = DateTime.strptime(params[:end_time],"%Y-%m-%d %H:%M:%S")
    consumer_ids = Seller.find_by_contact_id(current_user.id).consumer_ids
    trans_list = Transaction.where("enabled=1 and created_at>=? and created_at<=? and consumer_id in (?)",start_time,end_time, consumer_ids)
    list = []
    trans_list.each {|a|
      next if a.nil?
      cost = 0
      a.orders.each {|order|
        next if order.item.nil? || order.nil? || order.item.specification.nil?
        cost += order.actual_cost
      }
      obj = {
        :brand => a.consumer.name,
        :phone => a.consumer.consignee_phone,
        :contact_name => a.consumer.consignee_name,
        :item_num => a.orders.count,
        :cost => cost.round(2),
        :trans_id=>a.id
    }
      list.push(obj)
      obj = {}
    }
    api_render_result({:trans_infos => list}, E_SUCCESS)
  end

  def get_order_list
    unless current_user.seller?
      api_render_result(nil, E_USER_ROLE_ERROR)
      return
    end
    unless params[:client_uuid] && params[:trans_id] && current_user
      api_render_result(nil, E_API_PARAMETER_ERROR)
      return
    end
    track_api({"user_id" => current_user.id, "client_uuid" => "#{params[:client_uuid]}", "lat" => "#{params[:latitude]}", "lng" => "#{params[:longitude]}"}) if current_user

    # consumer_ids = Seller.find_by_contact_id(current_user.id).consumer_ids
    # order_list = Transaction.where("id=? and consumer_id in (?)", params[:trans_id], consumer_ids)
    order_list = Transaction.where("id=?", params[:trans_id])
    list= []
    order_list.first.orders.each {|a|
      next if a.nil? || a.item.nil?
      obj = {
        :item_name => a.item.name,
        :item_spec => a.item.specification.spec,
        :price_spec => a.item.specification.price,
        :item_number => a.item_number,
        :actual_cost => a.actual_cost,
        :trans_id=>a.transaction.id
      }
      list.push(obj)
      obj = {}
    }
    api_render_result({:order_info => list}, E_SUCCESS)
  end

  def csm_havent_ord
    unless current_user.seller?
      api_render_result(nil, E_USER_ROLE_ERROR)
      return
    end
    unless params[:client_uuid] && params[:start_time] && params[:end_time] && current_user
      api_render_result(nil, E_API_PARAMETER_ERROR)
      return
    end
    track_api({"user_id" => current_user.id, "client_uuid" => "#{params[:client_uuid]}", "lat" => "#{params[:latitude]}", "lng" => "#{params[:longitude]}"}) if current_user

    consumer_ids = Seller.find_by_contact_id(current_user.id).consumer_ids
    start_time = DateTime.strptime(params[:start_time],"%Y-%m-%d %H:%M:%S") - 1
    end_time = DateTime.strptime(params[:end_time],"%Y-%m-%d %H:%M:%S")
    # csm = Consumer.where("NOT EXISTS (select * from transactions where transactions.Consumer_id = consumers.id and transactions.created_at >= ? AND transactions.created_at <= ? AND id in (?))", start_time, end_time, consumer_ids)
    csm = Consumer.where("NOT EXISTS (select * from transactions where transactions.Consumer_id = consumers.id and transactions.created_at >= ? AND transactions.created_at <= ?) AND id in (?)", start_time, end_time, consumer_ids)
    list = []
    csm.each {|a|
      obj = {
        :brand => a.name,
        :name => a.consignee_name,
        :phone => a.consignee_phone
      }
      list.push(obj)
      obj = {}
    }
    api_render_result({:csm_info => list}, E_SUCCESS)
  end

  def save_due_for_trans
    unless current_user.seller?
      api_render_result(nil, E_USER_ROLE_ERROR)
      return
    end
    unless params[:client_uuid] && params[:due]  && params[:trans_id] && params[:status] && current_user
      api_render_result(nil, E_API_PARAMETER_ERROR)
      return
    end
    track_api({"user_id" => current_user.id, "client_uuid" => "#{params[:client_uuid]}", "lat" => "#{params[:latitude]}", "lng" => "#{params[:longitude]}"}) if current_user

    consumer_ids = Seller.find_by_contact_id(current_user.id).consumer_ids
    due = params[:due]
    status = params[:status]
    params[:status] == "0" ? status = 1 : status = 0
    trans = Transaction.where("id=? and  enabled=? and consumer_id in (?)", params[:trans_id], 1, consumer_ids)
    list = []
    trans.first.update_column(:status, status) if trans
    trans.first.update_column(:due, due)  if trans
    obj = {
        :due => trans.first.due,
        :status => trans.first.status
      }
    list.push(obj)
    obj = {}
    api_render_result({:trans_info => list}, E_SUCCESS)
  end

  def get_trans_status
    unless current_user.seller?
      api_render_result(nil, E_USER_ROLE_ERROR)
      return
    end
    unless params[:client_uuid] && params[:start_time] && params[:end_time] && params[:status] && current_user
      api_render_result(nil, E_API_PARAMETER_ERROR)
      return
    end
    track_api({"user_id" => current_user.id, "client_uuid" => "#{params[:client_uuid]}", "lat" => "#{params[:latitude]}", "lng" => "#{params[:longitude]}"}) if current_user

    consumer_ids = Seller.find_by_contact_id(current_user.id).consumer_ids
    start_time = DateTime.strptime(params[:start_time],"%Y-%m-%d %H:%M:%S") - 1
    end_time = DateTime.strptime(params[:end_time],"%Y-%m-%d %H:%M:%S")
    status = params[:status]
    trans_list = Transaction.where("status=? and enabled=1 and created_at>=? and created_at<=? and consumer_id in (?)", status, start_time,end_time,consumer_ids)
    list = []
    trans_list.each {|a|
      next if a.nil?
        cost = 0
        a.orders.each {|order|
          next if order.nil? || order.item.nil?
          cost += order.actual_cost
        }
    obj = {
        :brand => a.consumer.name,
        :name => a.consumer.consignee_name,
        :phone => a.consumer.consignee_phone,
        :item_num => a.orders.count,
        :trans_cost => cost.round(2),
        :trans_id => a.id,
        :due => a.due,
        :status => a.status
    }
      list.push(obj)
      obj = {}
    }
    api_render_result({:csm_info => list}, E_SUCCESS)
  end

  # actions for seller_admin
  def get_trans_statistics
    unless current_user.seller_admin?
      api_render_result(nil, E_USER_ROLE_ERROR)
      return
    end
    unless params[:client_uuid] && params[:time] && current_user
      api_render_result(nil, E_API_PARAMETER_ERROR)
      return
    end
    track_api({"user_id" => current_user.id, "client_uuid" => "#{params[:client_uuid]}", "lat" => "#{params[:latitude]}", "lng" => "#{params[:longitude]}"}) if current_user
    start_time = DateTime.strptime(params[:time],"%Y-%m-%d %H:%M:%S") - 1
    end_time = DateTime.strptime(params[:time],"%Y-%m-%d %H:%M:%S")
    zones = Zone.all

    list = []
    zones.each do |zone|
      count =  Transaction.where("created_at>=? and created_at<=? and enabled=1",start_time,end_time).where("consumer_id in (?)", Zone.find(zone.id).consumer_ids).map(&:consumer_id).uniq.count
      obj = {
          :count => count,
          :zone_name => zone.name
      }
      list.push(obj)
      obj = {}
    end
    api_render_result({:csm_info => list}, E_SUCCESS)
  end

end
