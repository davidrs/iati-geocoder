Gem::Specification.new do |s|
  s.name        = 'TextGeocoder'
  s.version     = '0.0.4'
  s.date        = '2013-08-25'
  s.summary     = "A module for geocoding an unstructured body of text."
  s.description = "This module parses a body of unstructured text, pulls out all city and region names, and geo-encodes them."
  s.authors     = ["David Rust-Smith","Paulo","Berk","Phil"]
  s.email       = 'david@smewebsites.com'
  s.files       = ["lib/text_geocoder.rb","lib/blacklist.txt","lib/adm1codes.txt","lib/adm2codes.txt"]
  s.homepage    =
    'http://rubygems.org/gems/text_geocoder'
  s.license       = 'Apache 2'
end