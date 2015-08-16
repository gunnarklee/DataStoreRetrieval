__author__ = 'Safyre'
# http://doc.scrapy.org/en/latest/intro/tutorial.html
# to use go to project's top level directory and run:
# scrapy crawl tcgaSP
import scrapy, urlparse
from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor
from test_tcga_scrape.items import TcgaItem

#class tcgaSpider(scrapy.Spider):
class tcgaSpider(CrawlSpider):
    name = "tcgaSP"
    allowed_domains = ["https://tcga-data.nci.nih.gov"]
    start_urls = [
        "https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/distro_ftpusers/anonymous/tumor/brca/"
    ]

    rules = [Rule(SgmlLinkExtractor(allow = ['\/'], deny = ['(\?C=)\w(\;)\w(\=)\w'] ), callback = 'parse', follow = True)]


    def parse(self, response):
        for href in response.xpath('//pre/a/@href').extract()[4:]:# start after parent directory
            #url = response.urljoin(href.extract())
            #url = href.extract()
            abs_url = urlparse.urljoin("https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/distro_ftpusers/anonymous/tumor/brca/", href)
            yield scrapy.Request(abs_url, callback=self.parse_dir_contents)

    def parse_dir_contents(self, response):
        #filename = response.url.split("/")[-2] #+ '.html'
        #with open(filename, 'wb') as f:
        #    f.write(response.body)
        #f.close()
        for sel in response.xpath('//pre'):
            item = TcgaItem()
            #title = sel.xpath('a/text()').extract()
            #link = sel.xpath('a/@href').extract()
            #desc = sel.xpath('text()').extract()
            item['title'] = sel.xpath('a/text()').extract()
            item['link'] = sel.xpath('a/@href').extract()
            print item['title'], item['link']
        return item

    #filename = response.url.split("/")[-2] + '.html'
    #with open(filename, 'wb') as f:
    #    f.write(response.body)