# Craigslist Listing Notifications
Sends an email with new listings for a provided keywords.

The repo contains the code for the lambda function as well as the
SQL queries for creating the tables used by the lambda function.

The lambda function is invoked from a stored procedure which is
executed on a 12 hour schedule.
