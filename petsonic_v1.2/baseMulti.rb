require 'curb'
require 'nokogiri'
require 'ruby-progressbar'
require 'csv'

class ParserBasic
  @@ParamsItem = []
  def initialize
    puts "Enter url addres:"
	@inputUrl = gets.chomp
	puts "Enter name of the file:"
	@nameFile = gets.chomp
  end

  def saveCSV(nameFile)
	puts "Saving Items info into #{@nameFile}.csv"
	CSV.open("#{nameFile}.csv","w") do |wr|           
	wr << ["Name", "Price", "Image"]
		@@ParamsItem.each { |params| wr << params }
	end
  end

  def loadPage(inputUrl=@inputUrl)
	http = Curl.get(inputUrl) do |http|                   
	  http.headers['User-Agent']="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36"
	end
	case http.header_str.split(/[\r\n]+/)[0].split()[1]
	when 200.to_s
	  Nokogiri::HTML.parse(http.body_str)
	else
	  false
	 end
  end

  def getUrlPages(html)
	urlPages = Array.new
	html.xpath("//a[@class='product-name']/@href").each { |urlPage| urlPages << urlPage }
	  return urlPages
	end

  def getInfo(html)
    setParamsItem = [[], [], []]
	name = html.xpath("//div[@class='primary_block row']//h1[@class='product_main_name']").text()
	html.xpath("//div[@id='attributes']//span[@class='radio_label']/child::text()").each do |partName|
	  fullNames = name + " - " + partName
	  setParamsItem[0] << fullNames
	end
	html.xpath("//div[@id='attributes']//span[@class='price_comb']/child::text()").each do |priceInt|  
	  setParamsItem[1] << priceInt.to_s.split()[0]
	  setParamsItem[2] << html.xpath("//div[@id='image-block']//img[@id='bigpic']/attribute::src").to_s                                    
	end
	@@ParamsItem.concat(setParamsItem.transpose)
  end
		
  def runScan(inputUrl=@inputUrl)
    case inputUrl =~ /(\d+)$/
	when nil 
	  puts "Parsing Product page №1 in progress.."
	else 
	  puts "Parsing Product page №#{$1} in progress.."
	end
	pageHtml = loadPage(inputUrl)
	urlItems = getUrlPages(pageHtml)
	progressbar = ProgressBar.create(:total => urlItems.size)
	threads = []
	urlItems.each do |url|
	  threads << Thread.new do
	    getInfo(loadPage(url))
	    progressbar.increment
	  end
	end
	threads.each(&:join)
  end
end
