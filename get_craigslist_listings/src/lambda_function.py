import os

from bs4 import BeautifulSoup
import requests

from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine


Base = automap_base()
engine = create_engine(os.getenv('DATABASE_URI'))
Base.prepare(engine, reflect=True)

CraigslistListing = Base.classes.craigslist_listings
CraigslistSearchUrl = Base.classes.craigslist_search_urls
Keyword = Base.classes.keywords


def handler(event, context):
    session = Session(engine)

    craigslist_search_url_id = event['search_url_id']
    craigslist_search_url = session.query(CraigslistSearchUrl).get(
        craigslist_search_url_id)
    if not craigslist_search_url:
        return

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
            continue
        
        obj = CraigslistListing(
            craigslist_search_url_id=craigslist_search_url_id,
            listing_url=listing_url)
        session.add(obj)

    session.commit()
