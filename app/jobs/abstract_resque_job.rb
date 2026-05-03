# frozen_string_literal: true

class AbstractResqueJob
  include Resque::Plugins::Status

  def perform
    if @uuid.is_a?(Hash)
      @options = @uuid
      @uuid = Resque::Plugins::Status::Hash.generate_uuid
    end
  end

  def job_id
    @job_id ||= Resque::Plugins::Status::Hash.generate_uuid
  end
end
