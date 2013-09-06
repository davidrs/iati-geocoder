require 'text_geocoder'

contents = File.open("iati-data/PassTestIATI.xml", "rb").read

# returns json
puts TextGeocoder::geocode(contents, format: :json)  

# returns ruby array
# puts TextGeocoder::geocode(contents)  