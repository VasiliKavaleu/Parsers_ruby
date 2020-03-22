require 'curb'
require 'nokogiri'
require 'ruby-progressbar'
require 'csv'


name_of_file = 'auto'

puts 'Enter url addres:'
url = gets.chomp


def progress_bar()                                        # func of visualization
	array = Array.new(150)
	progressbar = ProgressBar.create(:total => array.size)
		array.each do |item|
		progressbar.increment
		sleep 0.00005
	end
end


CSV.open("#{name_of_file}.csv","w") do |wr|           # init csv with headers
	wr << ["Model", "Year", "Price", "Link"]
end


puts "Created #{name_of_file}.csv"

def load(url)										# func of loading 
	http = Curl.get(url) do |http|                    
		http.headers['User-Agent']="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36"
	end

	html = Nokogiri::HTML.parse(http.body_str)
	return html
end



def save_csv(data, name_of_file)					# func of saving to csv
	CSV.open("#{name_of_file}.csv","a") do |ap|           
		ap << data
		progress_bar()
	end
end


def parcer_page(url, name_of_file)				# main parser func

	html = load(url)
	
	model = html.xpath("//div[@class='listing-item-main']/div[@class='listing-item-title']/h4/a/@href").each do |href| 
		html_of_auto = load(href)
		data = []

		model = html_of_auto.xpath("//div[@class='card-header']/h1").text.split(',')[0].strip()
		year = html_of_auto.xpath("//div[@class='card-header']/h1").text.split(',')[1] 
		price = html_of_auto.xpath("//div[@class='card-price-main']/span[@class='card-price-main-secondary']").text().strip()

		data << model
		data << year
		data << price
		data << href

		puts "Adding #{model}"

		save_csv(data, name_of_file)
	
	end
	

	next_url = html.xpath("//li[@class='pages-arrows-item']/a").each do |html_of_next_href|   # paginator
		
		if html_of_next_href.text() == "Следующая страница →"
			href_of_next_page = html_of_next_href.xpath("@href").to_s
			
			puts "Next page in progress.."
			parcer_page(href_of_next_page, name_of_file)   # run parser of the next page
			
		end

	end
	
end


parcer_page(url, name_of_file)

puts "Parser is over!"
