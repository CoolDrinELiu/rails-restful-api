E_SUCCESS={:msg => "#{I18n.t 'errors.api.success'}", :code => 0}

# 0. common
E_API_PARAMETER_ERROR={:msg => "#{I18n.t 'errors.api.params_error'}", :code => 101}

# 1. user_controller
E_PHONE_EXIST={:msg  => "#{I18n.t 'errors.api.phone_exist'}", :code => 1001}
E_SELL_ID_INVALID={:msg => "#{I18n.t 'errors.api.sell_id_invalid'}", :code => 1002}
E_SMS_INVALID={:msg => "#{I18n.t 'errors.api.sms_invalid'}", :code => 1003}
E_NOT_ACTIVE={:msg => "#{I18n.t 'errors.api.user_not_active'}", :code => 1004}
E_PHONE_NOT_REGISTER={:msg => "#{I18n.t 'errors.api.phone_not_register'}", :code => 1005}
E_PASSWORD_NOT_MATCH={:msg => "#{I18n.t 'errors.api.passwd_not_match'}", :code => 1006}
E_PASSWORD_NOT_CORRECT={:msg => "#{I18n.t 'errors.api.passwd_not_correct'}", :code => 1007}
E_UPDATE_PHOTO_FAILED={:msg => "#{I18n.t 'errors.api.update_photo_failed'}", :code => 1008}
E_SAVE_USER_FAILED={:msg => "#{I18n.t 'errors.api.save_user_failed'}", :code => 1009}
E_USER_NOT_LOGIN_IN={:msg => "#{I18n.t 'errors.api.user_not_login'}", :code => 1010}
E_USER_TYPE_ERROR={:msg => "#{I18n.t 'errors.api.user_type_error'}", :code => 1011}
E_USER_SEND_SMS_ERROR={:msg => "#{I18n.t 'errors.api.user_send_sms_error'}", :code => 1012}
E_USER_ROLE_ERROR={:msg => "#{I18n.t 'errors.api.user_role_error'}", :code => 1013}

# 2. transaction_controller
E_EMPTY_TRANSACTION_BODY={:msg => "#{I18n.t 'errors.api.trans_body_empty'}", :code => 2001}
E_USER_IS_NOT_CONSUMER_CONTACT={:msg => "#{I18n.t 'errors.api.user_not_contact'}", :code => 2002}
E_TRANSACTION_ID_INVALID={:msg => "#{I18n.t 'errors.api.trans_id_invalid'}", :code => 2003}
E_TRANSACTION_NOT_EXISTS={:msg => "#{I18n.t 'errors.api.trans_not_exists'}", :code => 2004}
E_TRANSACTION_ALREADY_COMPLETE={:msg => "#{I18n.t 'errors.api.trans_already_complete'}", :code => 2005}
E_USER_IS_NOT_GENERAL={:msg => "#{I18n.t 'errors.api.user_not_general'}", :code => 2006}
E_TRANSACTION_NOT_ENOUGH={:msg => "#{I18n.t 'errors.api.cost_not_enough'}", :code => 2007}
E_TRANSACTION_OUTOF_TIME_RANGE={:msg => "#{I18n.t 'errors.api.trans_out_of_time'}", :code => 2008}
E_USER_IS_NOT_SELLER={:msg => "#{I18n.t 'errors.api.user_not_seller'}", :code => 2009}

# 3. item_controller
E_ITEM_NOT_EXISTS={:msg => "#{I18n.t 'errors.api.item_not_exists'}", :code => 3001}

# 4. consumer_controller
E_CONSUMER_NOT_EXISTS={:msg => "#{I18n.t 'errors.api.consumer_not_exists'}", :code => 4001}
E_USER_IS_ALREADY_CONTACT={:msg => "#{I18n.t 'errors.api.user_is_already_contact'}", :code => 4002}