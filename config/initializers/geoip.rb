$geoip = GeoIP.new(Rails.root.join('config', 'GeoIP.dat'))
$geocity = GeoIP.new(Rails.root.join('config', 'GeoLiteCity.dat'))