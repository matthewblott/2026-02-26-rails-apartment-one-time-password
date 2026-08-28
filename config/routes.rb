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

    controller :account do
      get "account", action: :index, as: :account
      get  "account/new",        action: :new,       as: :new_account
      post "account/send",       action: :send_code, as: :account_send_code
      get  "account/verify",     action: :verify,    as: :account_verify_code
      post "account/verify",     action: :create,    as: :account_create
    end

  end

  controller :auth do
    get  "auth",            action: :new,       as: :auth
    post "auth/send",       action: :send_code, as: :auth_send_code
    get  "auth/verify",     action: :verify,    as: :auth_verify_code
    post "auth/verify",     action: :create,    as: :auth_create
    delete "auth/sign_out", action: :destroy,   as: :auth_destroy
  end

  controller :guest_sessions do
    post   "session/guest",  action: :create,   as: :guest_session_create
  end

  controller :static_pages do
    get "about", action: :about
  end

  root "static_pages#home"

end
