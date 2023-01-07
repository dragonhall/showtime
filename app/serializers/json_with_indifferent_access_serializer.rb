# frozen_string_literal: true

class JsonWithIndifferentAccessSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(json)
    Rails.logger.debug "DEBUG: parsed JSON is #{json}"
    # obj = ActiveSupport::JSON.decode(json)
    # obj.is_a?(Hash) ? obj.with_indifferent_access : obj
    # obj.freeze
    {}
  end
end
