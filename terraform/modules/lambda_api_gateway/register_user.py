import boto3
import logging
from os import getenv
from urllib.parse import parse_qsl

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    print("Received event:", event)
    logger.info("Received event: %s", event)
    query_string = dict(parse_qsl(event["rawQueryString"]))
    logger.info("Parsed query string: %s", query_string)
    print("Parsed query string:", query_string)
    client = boto3.resource("dynamodb")

    db_table = client.Table(getenv("DB_TABLE_NAME"))
    try:
        print("Attempting to insert item:", query_string)
        response = db_table.put_item(Item=query_string)
        print("DynamoDB put_item response:", response)
        logger.info("DynamoDB put_item response: %s", response)
        return { "message": "Registered User Successfully" }
    except Exception as error_details:
        logger.error("Error during put_item operation: %s", error_details, exc_info=True)  # 捕获异常并记录堆栈信息
        print("Error during put_item operation:", error_details)
        return { "message": "Error registering user. Check Logs for more details." }
