require 'yaml' unless defined?(YAML)
require 'psych' unless defined?(Psych)

module YAML
  class << self
    alias_method :load, :unsafe_load if YAML.respond_to? :unsafe_load
  end
end

module Psych
  class << self
    alias_method :load, :unsafe_load if Psych.respond_to? :unsafe_load
  end
end
