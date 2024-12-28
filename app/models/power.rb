# frozen_string_literal: true

class Power
  include Consul::Power

  # @param user Admin
  def initialize(user)
    @user = user
  end

  power :admins do
    Admin if @user.super_admin?
  end

  power :channels do
    if @user.super_admin? then
      Channel.all
    else
      (@user.group.blank? ? [] : @user.group.channels)
    end
  end

  power :playlists do
    if @user.super_admin? then
      Playlist.all
    elsif @user.group.any?
      Playlist.where('playlists.channel_id IN(?)', @user.group.channels.map(&:id))
    else
      []
    end
  end
end
