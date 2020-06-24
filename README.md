# Craigslist Listing Notifications
Sends an email with new listings for a provided keyword.

The repo contains the code for the Lambda function as well as the
SQL queries for creating the necessary tables, stored procedures and
events.

The Lambda function can be executed manually or executed on a schedule by
the MySQL event scheduler.

### Lambda Setup
Create a new Python 3.7 Lambda and see [this tutorial](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html) to learn how to create a deployment package from
the code in the `craigslist/` directory.

### Aurora Setup
Setup an AWS Aurora MySQL Instance and execute the query in `sql/create_table.sql`.

Execute the query in `sql/create_scrape_keywords_procedure.sql`. Ensure to replace the
ARN placeholder with the ARN of the Lambda you just created.

Follow the steps [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Lambda.html) here to give Aurora permission to access Lambda.

You can manually scrape the keywords by executing this query:
```sql
CALL scrape_keywords();
```

Or you can now execute the query in `sql/create_scrape_keywords_event.sql` to create
an event that will execute the `scrape_keywords` stored procedure every 12 hours.

### Adding Keywords
If you want to receive notifications for specific category/keyword pair, insert a row
into the `keywords` table and the listings will be scraped on the next invocation of
`scrape_keywords`.

```sql
INSERT INTO keywords (email, category, keyword)
VALUES (
    'my@email.com',
    'category',
    'keyword'
);
```
