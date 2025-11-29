# frozen_string_literal: true

# Alias for Crm::CompanyPolicy to make Pundit work with Company model
# Pundit automatically looks for CompanyPolicy when authorizing Company model
# This is a standard Rails pattern when model and policy are in different namespaces
CompanyPolicy = Crm::CompanyPolicy
