clean:
	rm -rf build build.zip
	rm -rf __pycache__

fetch-dependencies:
	mkdir -p bin/

	# Get chromedriver
	curl -SL https://chromedriver.storage.googleapis.com/2.32/chromedriver_linux64.zip > chromedriver.zip
	unzip chromedriver.zip -d bin/

	# Get Headless-chrome
	curl -SL https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-29/stable-headless-chromium-amazonlinux-2017-03.zip > headless-chromium.zip
	unzip headless-chromium.zip -d bin/

	rm headless-chromium.zip chromedriver.zip

docker-build:
	docker build . -t get_craigslist_search_urls

docker-run:
	docker run\
		--env DATABASE_URI=$(DATABASE_URI)\
		--env PYTHONPATH=/var/task/src:/var/task/lib\
		--env PATH=/var/task/bin\
		--volume=$(shell pwd)/src/:/var/task/src/\
		get_craigslist_search_urls src.lambda_function.handler '$(payload)'

build-zip: clean
	mkdir build
	cp -r src build/.
	cp -r bin build/.
	cp -r lib build/.
	pip install -r requirements.txt -t build/lib/.
	cd build; zip -9qr build.zip .
	cp build/build.zip .
	rm -rf build
