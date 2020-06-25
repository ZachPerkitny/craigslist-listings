clean:
	rm -rf build build.zip
	rm -rf __pycache__

docker-build:
	docker build . -t get_craigslist_listings

docker-run:
	docker run\
		--env DATABASE_URI=$(DATABASE_URI)\
		--env PYTHONPATH=/var/task/src:/var/task/lib\
		--volume=$(shell pwd)/src/:/var/task/src/\
		get_craigslist_listings src.lambda_function.handler '$(payload)'

build-zip: clean
	mkdir build
	cp -r src build/.
	pip install -r requirements.txt -t build/lib/.
	cd build; zip -9qr build.zip .
	cp build/build.zip .
	rm -rf build
