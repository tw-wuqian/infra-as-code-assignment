import boto3
from os import getenv
from urllib.parse import parse_qsl


def lambda_handler(event, context):
    print("Received event:", event)
    query_string = dict(parse_qsl(event["rawQueryString"]))
    print("Parsed query string:", query_string)
    client = boto3.resource("dynamodb")

    db_table = client.Table(getenv("DB_TABLE_NAME"))
    try:
        print("Attempting to insert item:", query_string)
        response = db_table.put_item(Item=query_string)
        print("DynamoDB put_item response:", response)
        return { "message": "Registered User Successfully" }
    except Exception as error_details:
        print("Error during put_item operation:", error_details)
        return { "message": "Error registering user. Check Logs for more details." }
