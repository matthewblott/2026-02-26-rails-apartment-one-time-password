Rails.application.routes.draw do

  scope "/:user_id", constraints: { user_id: /\d+/ }, as: 'user' do
    controller :todos do
      get    'todos',          action: :index,            as: 'todos'
      get    'todos/new',      action: :new,              as: 'new_todo'
      post   'todos',          action: :create,           as: 'todos_create'
      delete 'todos',          action: :destroy_multiple, as: 'todos_destroy_multiple'

      get    'todos/:id',      action: :show,             as: 'todo'
      get    'todos/:id/edit', action: :edit,             as: 'todo_edit'
      patch  'todos/:id',      action: :update,           as: 'todo_update'
      delete 'todos/:id',      action: :destroy,          as: 'todo_destroy'
    end

    controller :settings do
      get "settings", action: :show, as: "settings"
    end

  end

  controller :registrations do
    get  "register",        action: :new,       as: "new_registration"
    post "register/send",   action: :send_code, as: "registration_send_code"
    get  "register/verify", action: :verify,    as: "registration_verify"
    post "register/verify", action: :create,    as: "registration_verify_create"
  end

  controller :sessions do
    post 'sign_in', action: :create
    delete 'sign_out', action: :destroy
  end

  controller :otp_enrolments do
    get  "otp/enable",               action: :new,       as: "otp_enrolment"
    post "otp/enable/send_code",     action: :send_code, as: "otp_enrolment_send_code"
    get  "otp/enable/verify",        action: :verify,    as: "otp_enrolment_verify"
    post "otp/enable/verify",        action: :create,    as: "otp_enrolment_verify_create"

    # A settings page linking to new_otp_enrolment_path for device users
    # new_otp_enrolment
    # get 'otp/enrol', to: '?', as: 'new_otp_enrolment'

  end

  controller :otp_sessions do
    get  "otp/sign_in",      action: :new,       as: "otp_sign_in"
    post "otp/send_code",    action: :send_code, as: "otp_send_code"
    get  "otp/verify",       action: :verify,    as: "otp_verify"
    post "otp/verify",       action: :create,    as: "otp_verify_create"
  end

  controller :static_pages do
    get 'about',   action: :about
  end

  root "static_pages#home"

end
