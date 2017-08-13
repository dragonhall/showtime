# @type $geoip [GeoIP] GeoIP object with countries
$geoip = GeoIP.new(Rails.root.join('config', 'GeoIP.dat'))
# @type $geocity [GeoIP] GeoIP object with cities
$geocity = GeoIP.new(Rails.root.join('config', 'GeoLiteCity.dat'))