# -*- coding: utf-8 -*-

# Scrapy settings for test_tcga_scrape project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#

BOT_NAME = 'test_tcga_scrape'

SPIDER_MODULES = ['test_tcga_scrape.spiders']
NEWSPIDER_MODULE = 'test_tcga_scrape.spiders'

# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'test_tcga_scrape (+http://www.yourdomain.com)'
