# Coding Rules

## General

- Use spaces instead of tabs.
- Always use 2 spaces for tabs.

## Rails

- We follow Rails 8 conventions.
- We use the `rails-mcp-server` for project introspection.
- When writing AI-related logic, follow the patterns at RubyLLM.com.
- Prioritize `Hotwire` and `Stimulus` for frontend interactions.
- Avoid using Rails tag helpers, use HTML elements instead.

## Html

Make use of semantic elements.

Avoid using the `div` element and if an element isn't available then create one, for example favour `<menu-item>` over `<div class="menu-item">`. Try and make names web component friendly. Also don't create elements where they aren't necessary, for example favour `<header>` over `<card-header>`.
