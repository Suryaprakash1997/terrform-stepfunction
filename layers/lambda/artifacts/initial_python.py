import json

def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"  # Ensures HTTP response format
        },
        "body": json.dumps({"message": "Hello from Lambda!"})
        }