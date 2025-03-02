# Consult the following documentation for all settings available:
#
#     https://docs.scrapy.org/en/latest/topics/settings.html

BOT_NAME = "pokeapi"
SPIDER_MODULES = ["crawler.spiders"]

# See https://docs.scrapy.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
    "crawler.pipelines.IndexJsonWriterPipeline": 300,
}
