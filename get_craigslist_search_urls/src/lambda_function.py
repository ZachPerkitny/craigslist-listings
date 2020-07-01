import logging
import os
from urllib.parse import urlencode

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy.pool import NullPool
from sqlalchemy import create_engine


logger = logging.getLogger()
logger.setLevel(logging.INFO)

Base = automap_base()
engine = create_engine(os.getenv('DATABASE_URI'), poolclass=NullPool)
Base.prepare(engine, reflect=True)

CraigslistSearchUrl = Base.classes.craigslist_search_urls
Keyword = Base.classes.keywords


def handler(event, context):
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-remote-fonts')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--window-size=1280x1280')
    chrome_options.add_argument('--user-data-dir=/tmp/user-data')
    chrome_options.add_argument('--hide-scrollbars')
    chrome_options.add_argument('--enable-logging')
    chrome_options.add_argument('--log-level=0')
    chrome_options.add_argument('--v=99')
    chrome_options.add_argument('--single-process')
    chrome_options.add_argument('--data-path=/tmp/data-path')
    chrome_options.add_argument('--ignore-certificate-errors')
    chrome_options.add_argument('--homedir=/tmp')
    chrome_options.add_argument('--disk-cache-dir=/tmp/cache-dir')
    chrome_options.add_argument('--disable-browser-side-navigation')
    chrome_options.add_argument('--no-proxy-server')
    chrome_options.add_argument('user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36')
    chrome_prefs = {}
    chrome_options.experimental_options["prefs"] = chrome_prefs
    chrome_prefs["profile.default_content_settings"] = {"images": 2}
    chrome_prefs["profile.managed_default_content_settings"] = {"images": 2}
    chrome_options.binary_location = os.getcwd() + "/bin/headless-chromium"

    driver = webdriver.Chrome(chrome_options=chrome_options)

    keyword_id = event['keyword_id']
    session = Session(engine)
    keyword = session.query(Keyword).get(keyword_id)
    if keyword is None:
        return
    url = 'https://www.searchtempest.com/search?' + urlencode({
        'search_string': keyword.keyword,
        'category': keyword.category_id,
        'subcat': keyword.subcategory_id,
        'cityselect': 'zip',
        'location': keyword.zip_code,
        'maxDist': keyword.within,
        'Region': 'combined'
    })
    logger.info("getting url {0}".format(url))
    driver.get(url)

    container = WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.ID, 'directResults'))
    ) 

    i = 0
    for link in container.find_elements_by_class_name('groupHref'):
        search_url = link.get_attribute('href')
        obj = CraigslistSearchUrl(keyword_id=keyword_id, search_url=search_url)
        logger.info("adding new craigslist search url: {0}".format(search_url))
        session.add(obj)
        i += 1

    logger.info("added {0} new search urls".format(i))

    session.commit()
    session.close()
