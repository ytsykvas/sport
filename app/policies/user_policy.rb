# frozen_string_literal: true

# Alias for Admin::UserPolicy to make Pundit work with User model
# Pundit automatically looks for UserPolicy when authorizing User model
# This is a standard Rails pattern when model and policy are in different namespaces
UserPolicy = Admin::UserPolicy
