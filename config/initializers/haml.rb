# frozen_string_literal: true

Haml::Template.options[:ugly] = Rails.env.production?
Haml::Template.options[:remove_whitespace] = Rails.env.production?
