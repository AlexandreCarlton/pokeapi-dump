"""
Models for scraped items.

See https://docs.scrapy.org/en/latest/topics/items.html
"""

from dataclasses import dataclass
from typing import Any

import scrapy

@dataclass
class PokeapiJsonItem:
    url: str
    json: Any
