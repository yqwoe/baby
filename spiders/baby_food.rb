require 'kimurai'

class BabyFood < Kimurai::Base
  @name = "baby_food"
  @start_urls = ["https://baike.pcbaby.com.cn/meishi.html"]
  @engine = :selenium_chrome
  @config = {
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      before_request: { delay: 4..7 }
  }
  def parse(response, url:, data: {})
    item = {}
    @category_names = response.xpath("//div[@class='baike-th-name']").map {|a| a.text.squish }
    item[:tags] = Array.new

    response.xpath("//div[@class='baike-tb clearfix']").each_with_index do |a,i|
      logger.info i
      next if @category_names[i].nil?
      @data = {
        title: @category_names[i],
        children: Array.new
      }
      # logger.info a.xpath("//div[@class='baike-tb-dl']")
      a.xpath("//div[@class='baike-tb-dl']").each_with_index do |aa,index|
        # logger.info aa.css("/dl/dt/a").text
        # logger.info aa.css("/dl/dt/a").first["href"]
        @children = {
            title: aa.css("/dl/dt/a").text.squish,
            url: aa.css("/dl/dt/a").first["href"],
            children: Array.new
        }

        aa.css("/dl/dd/span").each  do |aaa|
          data = {
              title: aaa.css("/a").text.squish,
              url: aaa.css("/a").first["href"]
          }
          @children[:children] << data
          request_to :parse_post, url: "https:#{aaa.css("/a").first["href"]}",data: data
        end
        @data[:children] <<  @children

      end
      item[:tags] << @data
    end
    save_to "results.json", item, format: :pretty_json
  end

  def parse_post(response, url:, data: )
    #  response.xpath("//p[@class='m-th pt22']").each do |p|
    #    logger.info p.css("a").text
    # end
    logger.info response.xpath("//div[@class='l-tbody']")
    # data[:page_title] =  response.xpath("//p[@class='m-th pt22']/a").text
    data[:page_content] =  response.xpath("//div[@class='l-tbody']")
  end
end

BabyFood.crawl!
