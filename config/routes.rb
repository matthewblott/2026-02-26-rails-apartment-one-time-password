Rails.application.routes.draw do

  scope "/:user_id", constraints: { user_id: /\d+/ }, as: :user do
    controller :todos do
      get    "todos",          action: :index,            as: :todos
      get    "todos/new",      action: :new,              as: :new_todo
      post   "todos",          action: :create,           as: :todos_create
      delete "todos",          action: :destroy_multiple, as: :todos_destroy_multiple

      get    "todos/:id",      action: :show,             as: :todo
      get    "todos/:id/edit", action: :edit,             as: :todo_edit
      patch  "todos/:id",      action: :update,           as: :todo_update
      delete "todos/:id",      action: :destroy,          as: :todo_destroy
    end

    controller :settings do
      get "settings", action: :show, as: :settings
    end
  end

  controller :registrations do
    get  "register",        action: :new,       as: :registration
    post "register/send",   action: :send_code, as: :registration_send_code
    get  "register/verify", action: :verify,    as: :registration_verify_code
    post "register/verify", action: :create,    as: :registration_create
  end

  controller :guest_sessions do
    post   "session/guest",  action: :create,   as: :guest_session_create
  end

  controller :user_security do
    get  "security",        action: :new,       as: :security
    post "security/send",   action: :send_code, as: :security_send_code
    get  "security/verify", action: :verify,    as: :security_verify_code
    post "security/verify", action: :create,    as: :security_create
  end

  controller :sessions do
    get  "session",            action: :new,       as: :session
    post "session/send",       action: :send_code, as: :session_send_code
    get  "session/verify",     action: :verify,    as: :session_verify_code
    post "session/verify",     action: :create,    as: :session_create
    delete "session/sign_out", action: :destroy,   as: :session_destroy
  end

  controller :static_pages do
    get "about", action: :about
  end

  root "static_pages#home"

end
