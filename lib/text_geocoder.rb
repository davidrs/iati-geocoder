require 'nokogiri'
require 'iso_country_codes'
require 'geocoder'

module TextGeocoder
  extend self
  
	def path_to_resources
		File.join(File.dirname(File.expand_path(__FILE__)), '')
	end
  
	def geocode(contents, options={})

		response = Nokogiri::XML(contents)


		# Create blacklist of filler words
		blacklist = []
		File.open(path_to_resources+"/blacklist.txt").each_line do |line|
			blacklist << line.strip
		end

		# Create whitelist of region and city names
		whitelist = []
		lineArray = []
		File.open(path_to_resources+"/adm1codes.txt", "r:UTF-8").each_line do |line|
			#get adm2 name
			whitelist << line.strip.split("\t")[1].strip.split(" ")
			
			# add ascii name, unless duplicate
			unless line.strip.split("\t")[1].strip ==  line.strip.split("\t")[2].strip
				whitelist << line.strip.split("\t")[2].strip.split(" ")
			end
		end

		File.open(path_to_resources+"/adm2codes.txt", "r:UTF-8").each_line do |line|
			#get city name
			whitelist << line.strip.split("\t")[1].strip.split(" ")
			
			# add ascii name, unless duplicate
			unless line.strip.split("\t")[1].strip ==  line.strip.split("\t")[2].strip
				whitelist << line.strip.split("\t")[2].strip.split(" ")
			end
		end
		whitelist.flatten!

		results=[]
		# loop each activity
		response.xpath("//iati-activity").each do |activity|
			
			# get iati-identifier
			iati_id = activity.at("iati-identifier").text

			# store recipient country 
			rcpt_country = activity.at("recipient-country")
			hash={:uid => iati_id}
			# eliminate records with multi country data
			if rcpt_country and rcpt_country.attr("percentage") == "100"
				
				# find country name
				country = IsoCountryCodes.find(rcpt_country.attr("code")).name

				# loop each description in activities
				Nokogiri::XML(activity.to_s).xpath("//description").each do |desc|

					# find the correct and English description 
					if desc.attr("type") and desc.attr("xml:lang") == "en"

						# TODO: adjust code to keep groups of uppercase words as a single entity		
					
						query=desc.text.scan(/([[:upper:]][[:lower:]]+\s?)+/)
						query.each do |x|
							x[0].strip!
						end
						query.uniq!
						hash[:positions]=[]
						query.each do |q|
						if whitelist.include? q[0].strip and !blacklist.include? q[0].strip 
								coords=Geocoder.search("#{q[0].strip} #{country}")
								sleep 0.20
								
								unless coords.nil?
									coords.each do |c|

										if c.country == country
										
												# TODO: If a geocode request returns multiple responses
												#			Throw out any results that do not contain the search term in address
												#			If 2 responses have the exact same address just merge them.
											hash[:positions] << { :location => q[0].strip, :latitude => c.latitude, :longitude => c.longitude }
										end
									end
								end

							end
						end

						if hash[:positions].empty?
							coords=Geocoder.search("#{country}")
							unless coords.nil?
								hash[:positions] << { :location => country, :latitude => coords[0].latitude, :longitude => coords[0].longitude }
								hash[:precision] = "country"
							end
						else
							hash[:precision] = "region-or-city"
						end

					end
				end
			else
				hash[:positions]=[]
				hash[:precision]="none"
			end
			results << hash
		end # end of loop
		number_of_results={:countries => results.select { |r| r[:precision] == "country" }.count, :not_found => results.select { |r| r[:precision] == nil }.count, :city_or_region => results.select { |r| r[:precision] == "region-or-city" }.count }
		results << number_of_results
		if options[:format] == :json
			return results.to_json
		else
			return results
		end
	end
end