Rails.application.routes.draw do

  scope "/:user_id", constraints: { user_id: /\d+/ }, as: :user do
    controller :home do
      get "", action: :index, as: :home
    end

    controller :todos do
      get    "todos",          action: :index,            as: :todos
      get    "todos/new",      action: :new,              as: :new_todo
      post   "todos",          action: :create,           as: :todos_create
      delete "todos",          action: :destroy_multiple, as: :todos_destroy_multiple

      get    "todos/:id",      action: :edit,             as: :todo
      patch  "todos/:id",      action: :update,           as: :todo_update
      delete "todos/:id",      action: :destroy,          as: :todo_destroy
    end

    controller :account do
      get    "account",           action: :index,            as: :account
      get    "account/new",       action: :new,              as: :new_account
      post   "account/send-code", action: :send_code,        as: :account_send_code
      get    "account/verify",    action: :verify,           as: :account_verify
      post   "account/verify",    action: :verify_code,      as: :account_verify_code
      get    "account/sign-out",  action: :confirm_sign_out, as: :confirm_account_sign_out
      delete "account/sign-out",  action: :sign_out,         as: :account_sign_out
      get    "account/delete",    action: :confirm_delete,   as: :confirm_account_delete
      delete "account",           action: :destroy,          as: :account_destroy
    end

  end

  controller :auth do
    get  "auth",            action: :index,     as: :auth
    get  "auth/new",        action: :new,       as: :new_auth
    post "auth/send",       action: :send_code, as: :auth_send_code
    get  "auth/verify",     action: :verify,    as: :auth_verify_code
    post "auth/verify",     action: :create,    as: :auth_create
  end

  controller :guest_sessions do
    post   "session/guest",  action: :create,   as: :guest_session_create
  end

  controller :static_pages do
    get "index", action: :index
    get "info", action: :info
    get "terms", action: :terms
    get "privacy", action: :privacy
  end

  root "static_pages#splash"

end
