require 'kimurai'
require 'mongo'
class BabyFood < ApplicationSpider
  @name = "baby_food"
  @start_urls = ["https://baike.pcbaby.com.cn"]
  def parse(response, url:, data: {})
    @collection = $mongodb[:categories]
    @category_names = response.xpath("//div[@class='baike-th main']").each do |row|
      @c = @collection.find({
          title: row.css("/a").text.squish
                            }).first
      data = {
          title: row.css("/a").text.squish,
          url: "https:#{row.css("/a").first["href"]}"
      }
      if @c.nil?
        @collection.insert_one(data)
      end
    end

    # save_to "results.json", item, format: :pretty_json
  end
end

BabyFood.crawl!
