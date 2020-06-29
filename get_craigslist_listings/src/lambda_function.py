import logging
import os

from bs4 import BeautifulSoup
import requests

from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine


logger = logging.getLogger()
logger.setLevel(logging.INFO)

Base = automap_base()
engine = create_engine(os.getenv('DATABASE_URI'))
Base.prepare(engine, reflect=True)

CraigslistListing = Base.classes.craigslist_listings
CraigslistSearchUrl = Base.classes.craigslist_search_urls
Keyword = Base.classes.keywords


def handler(event, context):
    keyword_id = event['keyword_id']
    session = Session(engine)
    craigslist_search_urls = session.query(CraigslistSearchUrl).filter_by(
        keyword_id=keyword_id)
    if not craigslist_search_urls.count():
        logger.warning("No search_urls available for keyword: {0}".format(keyword_id))
        return

    i = 0
    for craigslist_search_url in craigslist_search_urls:
        res = requests.get(craigslist_search_url.search_url)
        soup = BeautifulSoup(res.text, features='html.parser')
        listings = soup\
            .find(id='sortable-results')\
            .find_all('li', { 'class': 'result-row' })
        for listing in listings:
            listing_url = listing.a['href']
            listing = session.query(CraigslistListing)\
                .filter_by(listing_url=listing_url)\
                .first()
            if listing:
                logger.info("listing url already seen: {0}".format(listing_url))
                continue
            
            obj = CraigslistListing(
                craigslist_search_url_id=craigslist_search_url.id,
                listing_url=listing_url)
            logger.info("adding new craigslist listing url: {0}".format(listing_url))
            session.add(obj)
            i += 1

    logger.info("added {0} new listings".format(i))

    session.commit()
