# frozen_string_literal: true

module ClientInfo
  class Client
    include ActiveModel::Model

    attr_accessor :client_id, :address, :url, :flash_ver,
                  :country, :city, :flag, :user_id

    validates_presence_of :client_id
    validates_presence_of :address

    validates_numericality_of :client_id, only_integer: true
    validates_format_of :address, with: /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\Z/

    def platform
      parsed_flashver[:platform]
    end

    def flash_version
      parsed_flashver[:version]
    end

    # def user_id
    #   @user_id ||= parsed_query['uid'].blank? ? -1 : parsed_query['uid'].to_i
    # end

    # @return [FusionUser]
    def user
      user_id >= 0 && FusionUser.where(user_id: user_id).any? ? ::FusionUser.find(user_id) : nil
    end

    def as_json(_options = nil)
      {
        client_id: client_id,
        address: address,
        url: url,
        flash_version: parsed_flashver[:version],
        platform: parsed_flashver[:platform],
        country: country,
        city: city,
        flag: ActionController::Base.helpers.asset_path("flags/#{flag}.png"),
        user_id: user_id,
        avatar: user.blank? ? ActionController::Base.helpers.asset_path('icons/user.png') : user.avatar_url,
        user_name: user.blank? ? 'Anonymous' : user.name

      }
    end

    private

    def parsed_flashver
      @parsed_flashver ||= {}

      if @parsed_flashver.empty?
        pcs = flash_ver.scan(/\A(\w+)\s+([0-9,]+)\Z/).flatten

        @parsed_flashver[:platform] = case pcs[0]

                                      when 'LNX'
                                        'Linux'
                                      when 'WIN'
                                        'Windows'
                                      when 'MAC'
                                        'Macintosh'
                                      when 'FMLE'
                                        'FlashMediaEncoder'
                                      else
                                        "Unknown platform (#{pcs[0]})"
                                      end

        @parsed_flashver[:version] = pcs[1] ? pcs[1].tr(',', '.') : ''
      end

      @parsed_flashver
    end
  end
end
