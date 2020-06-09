# frozen_string_literal: true

Redis::Namespace.class_eval do
  def client
    _client
  end
end
