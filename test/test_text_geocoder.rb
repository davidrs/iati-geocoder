# require 'text_geocoder'
require '../lib/text_geocoder.rb'

#PassTestIATI.xml
contents = File.open("iati-data/aidData_malawai_large.xml", "rb").read

# returns json
puts TextGeocoder::geocode(contents, format: :json)  

# returns ruby array
# puts TextGeocoder::geocode(contents)  
