iati-geocoder
=============

Ruby gem for geoencoding IATI activities based on their description.

This module parses a body of unstructured text, pulls out all city and region names, and geo-encodes them.


Sample Call
-----------
	
	require 'text_geocoder'

	contents = File.open("myIATI.xml", "rb").read

	# returns json
	puts TextGeocoder::geocode(contents, format: :json)  
	
	# returns ruby array
	puts TextGeocoder::geocode(contents)  	
	

Input
-----
geocode(contents, options={})  

contents: IATI xml string.

options: 
* format: json 	# otherwise returns ruby object.
  
  
Output
------
json array of IATI uids, array of gps co-ords, and a level of precision

	[
		{ 
		uid: project id
		positions: {
			[{
				location: CapitalWord | CountryName
				lat: 45.2323
				lng: 34.5346,
				address: “”
			},...
			]
		}
		precision: country | none | region-or-city
		},...
	]


Psuedo Code
-----------

* Read the project description and country code.
* Pull out all of the capital letter words from the description.
* Ignore words that are all capital letters, these are just acronyms.
* Try to keep hyphenated words together and groups of capital letter words. (Saint-Joseph or Addis Abbaba)
* Compare these words to a white list of cities and regions of the world, courtesy of GeoNames.org
* Take our remaining list and pass them to Google to be geocoded.
* Throw out any geocoded results that aren’t in the parent country or don’t contain the keyword we sent in.
* If we only have a single successful result we can be confident this is where the project is. If we have multiple results we can’t be too sure, return an array of results, if no results are found fall back to the country’s co-ordinates.
* Return a json object with the original unique id, and gps co-ordinates.

Authors
-------
David Rust-Smith, Paulo, Berk, Phil
