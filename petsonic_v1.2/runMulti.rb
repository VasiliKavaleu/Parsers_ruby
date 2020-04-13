require_relative "baseMulti"

class OneThread < ParserBasic
  def main
	startTime = Time.now.to_i
	runScan
	@page = 2
	@nextUrl = "#{@inputUrl}" + "?p=#{@page}"
	until loadPage(@nextUrl) == false
	  runScan(@nextUrl)
	  @page +=1
	  @nextUrl = "#{@inputUrl}" + "?p=#{@page}"
	end
	saveCSV(@nameFile)
	finishTime = Time.now.to_i - startTime
    puts "Parsing is over! Running time is #{finishTime} sec."
  end
end

parser = OneThread.new
parser.main