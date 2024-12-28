# frozen_string_literal: true

module ApplicationHelper
  def na_or_s(check)
    !!check ? yield : 'N/A'
  end

  def widget(widget, global: false, fullpath: false)
    path = global ? "widgets/#{widget}" : widget

    if fullpath
      render path
    else
      render partial: path
    end
  end

  def geoip_country(address)
    $geoip.country(address).country_name
  end

  def geoip_flag(address)
    code = $geoip.country(address).country_code2.downcase
    image_tag "flags/#{code}.png"
  end

  def geoip_city(address)
    $geocity.city(address).city_name
  end
end
