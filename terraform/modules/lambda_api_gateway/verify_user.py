import boto3
import logging
from os import getenv
from urllib.parse import parse_qsl

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    s3_client = boto3.client("s3")
    try:
        logger.info("Received event: %s", event)
        query_string = dict(parse_qsl(event["rawQueryString"]))
        logger.info("query_string is: %s", query_string)
        item_found = is_key_in_db(db_key=query_string)
        result_file = "index.html" if item_found else "error.html"
        response = s3_client.get_object(Bucket=getenv("WEBSITE_S3"), Key=result_file)
        html_body = response["Body"].read().decode("utf-8")
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "text/html"},
            "body": html_body,
        }
    except Exception as error_details:
        logger.info("Error details is: %s",error_details)
        print(error_details)
        return "Error verifying user. Check Logs for more details."


def is_key_in_db(db_key):
    db_client = boto3.resource("dynamodb")
    db_table = db_client.Table(getenv("DB_TABLE_NAME"))
    try:
        response = db_table.get_item(Key=db_key)
        logger.info("Response is: %s", response)
        if "Item" not in response:
            logger.info(f"Item with key: {db_key} not found")
            return False
    except Exception as err:
        logger.info("Error Getting Item: %s", err)
        print(f"Error Getting Item: {err}")
        return False
    else:
        return True
