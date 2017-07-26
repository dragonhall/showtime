module ClientInfo

  class Client
    include ActiveModel::Model

    attr_accessor :client_id, :address, :url, :flash_ver

    validates_presence_of :client_id
    validates_presence_of :address

    validates_numericality_of :client_id, only_integer: true
    validates_format_of :address, with: %r{\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\Z}

    def platform
      parsed_flashver[:platform]
    end

    def flash_version
      parsed_flashver[:version]
    end

    def user_id
      qp = Rack::Utils.parse_query URI.parse(url).query
      qp['uid'].blank? ? -1 : qp['uid'].to_i
    end

    def user
      user_id >= 0 ? ::FusionUser.find(user_id) : nil
    end

    private

    def parsed_flashver
      @parsed_flashver ||= {}

      if @parsed_flashver.empty?
        pcs = flash_ver.scan(/\A(\w+)\s+([0-9,]+)\Z/).flatten

        case pcs[0]

          when 'LNX'
            @parsed_flashver[:platform] = 'Linux'
          when 'WIN'
            @parsed_flashver[:platform] = 'Windows'
          when 'MAC'
            @parsed_flashver[:platform] = 'Macintosh'
          when 'FMLE'
            @parsed_flashver[:platform] = 'FlashMediaEncoder'
          else
            @parsed_flashver[:platform] = "Unknown platform (#{pcs[0]})"
        end

        @parsed_flashver[:version] = pcs[1] ?  pcs[1].gsub(',', '.') : ""
      end

      @parsed_flashver
    end

  end
end
