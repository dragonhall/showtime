class ChannelsController < InheritedResources::Base

  respond_to :json

  private
    def channel_params
      params.require(:channel).permit(:name, :overlay_icon,
                                      :icon, :domain, :price)
    end
end

