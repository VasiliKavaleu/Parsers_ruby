require_relative "base"

class MultiThreading < ParserBasic
  def counterPage
	@totalPages = 1
	@page = 2
	@nextUrl = "#{@inputUrl}" + "?p=#{@page}"
	until loadPage(@nextUrl) == false
	  @totalPages += 1
	  @page += 1
	  @nextUrl = "#{@inputUrl}" + "?p=#{@page}"
	end
    return @totalPages
  end

  def runThr(pageThr1, pageThr2)
	if pageThr1 == 1
        @thread1Url = @inputUrl
    else
        @thread1Url = "#{@inputUrl}" + "?p=#{@pageThr1}"
    end
    thread1 = Thread.new{runScan(@thread1Url)}
    @thread2Url = "#{@inputUrl}" + "?p=#{pageThr2}"
    thread2 = Thread.new{runScan(@thread2Url)}
    thread1.join           	
    thread2.join
  end

  def multiThr
	startTime = Time.now.to_i
   	@pageThr1 = 1
	@pageThr2 = 2
    case counterPage % 2
   	when 1
      while @pageThr2 <= counterPage
        runThr(@pageThr1, @pageThr2)
        @pageThr1 +=2
        @pageThr2 +=2
      end

      if @pageThr1 == 1
        runScan()
      else
        @thread1Url = "#{@inputUrl}" + "?p=#{@pageThr1}"
        runScan(@thread1Url)
      end

	else
      while @pageThr1 <= counterPage
        runThr(@pageThr1, @pageThr2)
        @pageThr1 +=2
        @pageThr2 +=2
      end	
    end
    saveCSV(@nameFile)
    finishTime = Time.now.to_i - startTime
    puts "Parsing is over! Running time is #{finishTime} sec."
  end
end

parser = MultiThreading.new
parser.multiThr
