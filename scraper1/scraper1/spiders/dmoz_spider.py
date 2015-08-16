# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
import scrapy

class DmozSpider(scrapy.Spider):
    name = "dmoz"
    allowed_domains = ["dmoz.org"]
    start_urls = [
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/",
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"
        #"http://twitter.com/search?q=%23FIFAWWC%20since%3A2015-06-05%20until%3A2015-07-06&src=typd"

    ]


 #   def parse(self, response):
 #       for sel in response.xpath('//ul/li'):
 #           title = sel.xpath('a/text()').extract()
 #           link = sel.xpath('a/@href').extract()
 #           desc = sel.xpath('text()').extract()
 #           print title, link, desc

 #   def parse(self, response):
 #       filename = response.url.split("/")[-2] + '.html'
 #       with open(filename, 'wb') as f:
 #           f.write(response.body)

  #  def parse(self, response):
   #     for sel in response.xpath('//ul/li'):
    #         item = DmozItem()
     #        item['title'] = sel.xpath('a/text()').extract()
      #       item['link'] = sel.xpath('a/@href').extract()
       #      item['desc'] = sel.xpath('text()').extract()
        #     yield item


      def parse(self, response):
        for sel in response.xpath('//ul/li'):
            title = sel.xpath('a/text()').extract()
            link = sel.xpath('a/@href').extract()
            desc = sel.xpath('text()').extract()
            print title, link, desc
        filename = response.url.split("/")[-2] + '.html'
        with open(filename, 'wb') as f:
            f.write(response.body)