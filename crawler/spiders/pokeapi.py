import scrapy

from crawler.items import PokeapiJsonItem
from pathlib import Path


class PokeapiSpider(scrapy.Spider):

    name = "pokeapi"

    def __init__(self, base_url="http://localhost", dump_directory="dump",
                 endpoint_placeholder="ENDPOINT", *args, **kwargs):
        super(PokeapiSpider, self).__init__(*args, **kwargs)
        self.start_urls = [f"{base_url}/api/v2/"]

        self.base_url = base_url
        self.dump_directory = Path(dump_directory)
        self.endpoint_placeholder = endpoint_placeholder

    # PokeAPI only provides json (except for images/audio but we don't scrape these).
    def parse(self, response: scrapy.http.response.json.JsonResponse):
        url_by_resource: dict[str, str] = response.json()
        yield PokeapiJsonItem(url=response.url, json=url_by_resource)

        for url in url_by_resource.values():
            yield scrapy.Request(f"{url}?limit=100000", callback=self.parse_api_resource_list)

    def parse_api_resource_list(self, response: scrapy.http.response.json.JsonResponse):
        page = response.json()
        yield PokeapiJsonItem(url=response.url.split('?')[0], json=page)
        for result in page["results"]:
            yield scrapy.Request(result["url"], callback=self.parse_resource)

    def parse_resource(self, response: scrapy.http.response.json.JsonResponse):
        data = response.json()
        yield PokeapiJsonItem(url=response.url, json=data)
        if "/pokemon/" in response.url and "location_area_encounters" in data:
            yield scrapy.Request(url=f"{self.base_url}{data["location_area_encounters"]}", callback=self.parse_resource)
