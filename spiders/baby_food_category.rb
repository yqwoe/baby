require 'kimurai'
require 'mongo'
class BabyFoodCategory < ApplicationSpider
  @name = "baby_food_category"
  @c = $mongodb[:categories]

  @start_urls = []
  @c.find().each do |row|
    @start_urls << row["url"]
  end

  def parse(response, url:, data: {})
    @collection = $mongodb[:categories]

    @cateroy_parent = @collection.find({
                                           url: url
                                       }).first
    @posts = $mongodb[:posts]
    item = {}
    @category_names = response.xpath("//div[@class='baike-th-name']").map {|a| a.text.squish }
    #  response.xpath("//p[@clas
    item[:tags] = Array.new
    # logger.info response
    response.xpath("//div[@class='baike-tb clearfix']").each_with_index do |a,i|
      logger.info i
      next if @category_names[i].nil?

      result = @collection.insert_one({
                                          title: @category_names[i],
                                          parent_id: @cateroy_parent["_id"]
                                      })
      logger.info result
      @parent =  @collection.find({
                                      title: @category_names[i]
                                  }).first
      a.xpath("//div[@class='baike-tb-dl']").each_with_index do |aa,index|
        result = @collection.insert_one({
                                            title: aa.css("/dl/dt/a").text.squish,
                                            url: "https:#{aa.css("/dl/dt/a").first["href"]}",
                                            parent_id: @parent["_id"]
                                        })
        @parent1 =  @collection.find({
                                         title: aa.css("/dl/dt/a").text.squish
                                     }).first
        aa.css("/dl/dd/span").each  do |aaa|
          data = {
              title: aaa.css("/a").text.squish,
              url: "https:#{aaa.css("/a").first["href"]}",
              category_id: @parent1["_id"],
              actived: false
          }
          @posts.insert_one(data)
        end
      end
    end

    # save_to "results.json", item, format: :pretty_json
  end
end

BabyFoodCategory.crawl!
