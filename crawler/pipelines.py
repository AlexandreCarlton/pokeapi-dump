
import json
from pathlib import Path

import scrapy

from crawler.items import PokeapiJsonItem
from crawler.spiders.pokeapi import PokeapiSpider

class IndexJsonWriterPipeline:

    # We have only one spider so we can assume it's PokeapiSpider.
    def process_item(self, item: PokeapiJsonItem, spider: PokeapiSpider):
        path_segment = item.url[len(f"{spider.base_url}/"):]
        index_json = spider.dump_directory / path_segment / 'index.json'
        index_json.parent.mkdir(parents=True, exist_ok=True)

        json_text = (json.dumps(item.json, separators=(',', ':'))
                     .replace(spider.base_url, spider.endpoint_placeholder)
                     .replace("https://raw.githubusercontent.com/PokeAPI/cries/main", f"{spider.endpoint_placeholder}/static")
                     .replace("https://raw.githubusercontent.com/PokeAPI/sprites/master", f"{spider.endpoint_placeholder}/static"))

        index_json.write_text(json_text)

        if 'name' in item.json:
            name = item.json['name']
            name_path = (spider.dump_directory / path_segment).parent / name
            name_path.parent.mkdir(parents=True, exist_ok=True)

            # /api/v2/pokemon/bulbasaur -> 1
            # /api/v2/location/naranja-academy/uva-academy -> ../837
            relative_prefix = ''.join('../' for _ in range(name.count('/')))
            if not name_path.exists():
                name_path.symlink_to(f"{relative_prefix}{item.json['id']}", target_is_directory=True)

        return item
