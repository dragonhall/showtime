# frozen_string_literal: true

class ChannelsController < InheritedResources::Base
  respond_to :json

  layout false

  private

  def channel_params
    params.require(:channel).permit(:name, :logo,
                                    :icon, :domain, :stream_path,
                                    :trailer_before_id, :trailer_after_id)
  end
end
