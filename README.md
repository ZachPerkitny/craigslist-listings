# Craigslist Listings
Retrieves new Craigslist listings for a provided keyword and location.

The repo contains the code for the Lambda function as well as the
SQL queries for creating the necessary tables, stored procedures and
events.

The Lambda function can be executed manually or executed on a schedule by
the MySQL event scheduler.

### Requirements
Install Docker and dependencies
* `make fetch-dependencies`
* [Installing Docker](https://docs.docker.com/engine/installation/#get-started)
* [Installing Docker compose](https://docs.docker.com/compose/install/#install-compose)

### Running Locally
Run `make docker-build` to build each Lambda image and `make docker-run` to execute
the Lambda Functions locally.

### Running in the Cloud
Create two new Lambda Functions (Python 3.7) ane execute `make build-zip` in the `get_craigslist_search_urls` and 
`get_craigslist_listings` directories and upload the zipfiles to AWS.

Create an AWS Aurora MySQL Instance and execute the query in `sql/initialize.sql`. Remember to replace the ARN
placeholders with the ARNs of the Lambdas you just created.

Follow the steps [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Lambda.html) here to give Aurora permission to access Lambda.

The Lambda Function will be executed every 12 hours by the MySQL event scheduler OR:
You can manually scrape the keywords by executing this query:
```sql
CALL get_craigslist_listings();
```

### Adding Keywords
If you want to get listings for specific category/keyword pairs, insert a row
into the `keywords` table and the listings will be scraped on the next invocation of
`get_craigslist_listings`.

```sql
INSERT INTO keywords (email, category_id, keyword, zip_code, within)
VALUES (
    'my@email.com',
    (SELECT id FROM categories WHERE name='jobs'),
    'keyword',
    '55555',
    50000
);
```
