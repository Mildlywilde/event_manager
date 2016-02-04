require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_number(phone_number)
	number = phone_number.to_s.gsub(/\D/, "")
	if number.length < 10 || number.length > 11
		number = "Invalid Number"
	elsif number.length == 11
		if number[0] == 1
			number[0] = ""
		else
			number = "Invalid Number"
		end
	end

	return number
end


def legislators_by_zipcode(zipcode)
	legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thankyou_letters(id, form_letter)
	Dir.mkdir("output") unless  Dir.exists? "output"

	filename = "output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end

puts "EventManager Intialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
	id = row[0]
	name = row[:first_name]

	phone_number = clean_number(row[:homephone])

	zipcode = clean_zipcode(row[:zipcode])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	save_thankyou_letters(id, form_letter)

	puts phone_number
	
	
end