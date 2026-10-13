# Example Apartment One Time Password

Example Rails Todos application making use of the following gems:
- [Apartment](https://github.com/rails-on-services/apartment) for multi tenancy.
- [rotp](https://github.com/mdp/rotp) for passwordless signing in.
- [pagy](https://github.com/ddnexus/pagy) for pagination.

The index page implements infinate scroll using Turbo Frames.

The user can sign in with a guest account or create an account with a one time password. The excellent [Mailpit](https://github.com/axllent/mailpit) application is recommended for use with this project and the default port set in the `config/environments/development.rb` file is set to 1025.

## Getting Started

Install the correct libraries:
```
bundle insall
```

Run the migrations for the authentication database:
```
rails db:migrate:auth

```

Run the migrations for the tenant Todos database:
```

rails db:migrate:primary
```

To create a test user with records run the following:
```
rails db:seed
```
This creates the user `jane@example.com` with an OTP code of `123456`.

Run the Rails server with the following command:
```
rails server
```

