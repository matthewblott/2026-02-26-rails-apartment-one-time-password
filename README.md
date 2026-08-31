# Example Apartment One Time Password

Example Rails Todos application making use of the Apartment and rotp libraries.

The user can sign in with a guest account or create an account with a one time password. The excellent [Mailpit](https://github.com/axllent/mailpit) application is recommended for use with this project and the default port set in the `config/environments/development.rb` file is set to 1025.

## Getting Started

Install the correct libraries:
```
bundle insall
```

Vite is used for the front end. Bun is also used although you can swap that for npm or whatever tool you wish:
```
bun install
```

Run the migrations for the authentication database:
```
rails db:migrate:auth

```

Run the migrations for the tenant Todos database:
```

rails db:migrate:primary
```

Run both Vite and the Rails server with the following command:
```
bun dev
```
