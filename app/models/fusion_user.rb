# frozen_string_literal: true

class FusionUser < ApplicationRecord
  establish_connection :dragonhall

  default_scope { where(user_status: 0) }

  FUSION_URL = 'http://dragonhall.hu'
  DEFAULT_AVATAR = '/forum/images/Default.png'

  pretty_columns :user_

  def avatar_url
    avatar_file = user_avatar.empty? ? DEFAULT_AVATAR : "/images/avatars/#{user_avatar}"
    "#{FUSION_URL}#{avatar_file}"
  end

  def active?
    !user_status
  end
end
