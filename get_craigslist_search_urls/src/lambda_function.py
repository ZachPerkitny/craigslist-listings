import os
from urllib.parse import urlencode

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy.pool import NullPool
from sqlalchemy import create_engine


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
     
    caps = DesiredCapabilities().CHROME
    caps['pageLoadStrategy'] = 'none'

    driver = webdriver.Chrome(
        chrome_options=chrome_options,
        desired_capabilities=caps)

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
    driver.get(url)

    container = WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.ID, 'containerUS'))
    )
    driver.execute_script("window.stop();")

    for link in container.find_elements_by_class_name('thumbnailLink'):
        # HACK: SearchTempest likes to load a bunch of random shit,
        # and it makes the script run a lot slower so calling window.stop
        # a bunch solves this issue
        driver.execute_script("window.stop();")
        obj = CraigslistSearchUrl(
            keyword_id=keyword_id,
            search_url=link.get_attribute('href'))
        session.add(obj)

    session.commit()
