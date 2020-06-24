# Craigslist Listing Notifications
Sends an email with new listings for a provided keyword.

The repo contains the code for the lambda function as well as the
SQL queries for creating the tables used by the lambda function.

The lambda function is invoked from a stored procedure which is
executed on a 12 hour schedule.

### Lambda Setup
Create a new Python 3.7 Lambda and see [this tutorial](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html) to learn how to create a deployment package from
the code in the `craigslist/` directory.

### Aurora Setup
Setup an AWS Aurora MySQL Instance and execute the query in `sql/create_table.sql`.

Execute the SQL in `sql/create_scrape_keywords_procedure.sql`. Ensure to replace the
ARN placeholder with the ARN of the Lambda you just created.

Follow the steps [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Lambda.html) here to give Aurora permission to access Lambda.

You can run to ensure that Aurora can invoke the Lambda.
```sql
CALL scrape_keywords();
```

You can now optionally execute the SQL in `sql/create_scrape_keywords_event.sql` to create
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
