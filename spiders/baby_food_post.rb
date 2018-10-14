class BabyFoodPost < ApplicationSpider
  @name = "baby_food_post"
  @posts = $mongodb[:posts]

  @start_urls = []
  @posts.find({page_html:{'$exists':false}}).each do |row|
    @start_urls << row["url"]
  end


  def parse(response, url:, data: {})
    # data[:page_html] =  response.xpath("//div[@class='l-tbody']")
    # data[:page_content] =  response.xpath("//div[@class='l-tbody']").text
    # logger.info response.xpath("//div[@class='l-tbody']").to_html
    @posts = $mongodb[:posts]
    @post = @posts.find({
                            url: url
                        }).first
     @posts.update_one({
        _id: @post["_id"]
                        },@post.merge({
         page_html: response.xpath("//div[@class='l-tbody']").to_html ,
    :page_content => response.xpath("//div[@class='l-tbody']").text,
         :actived => true
                       }))

  end
end


BabyFoodPost.crawl!
