import os
from urllib.parse import urlencode

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine


Base = automap_base()
print(os.getenv('DATABASE_URI'))
engine = create_engine(os.getenv('DATABASE_URI'))
Base.prepare(engine, reflect=True)

CraigslistSearchUrl = Base.classes.craigslist_search_urls
Keyword = Base.classes.keywords


def handler(event, context):
    session = Session(engine)

    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--window-size=1280x1696')
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
    chrome_options.add_argument('user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36')
    chrome_options.binary_location = os.getcwd() + "/bin/headless-chromium"
     
    driver = webdriver.Chrome(chrome_options=chrome_options)

    keyword = Keyword.query.get(event['keyword_id'])

    url = 'https://www.searchtempest.com/search?' + urlencode({
        'search_string': keyword.keyword,
        'category': keyword.category,
        'cityselect': 'zip',
        'location': keyword.zip_code,
        'maxDist': keyword.within,
        'Region': 'combined'
    })
    driver.get(url)

    container = WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.ID, 'containerUS'))
    )
    for result in container.find_elements_by_class_name('directResult'):
        try:
            link = result.find_element_by_xpath('.//a[contains(@class, "thumbnailLink")]')
            session.add(CraigslistSearchUrls(
                keyword=keyword,
                search_url=link.get_attribute('href'))
            )
        except:
            continue

    session.commit()

    return None
