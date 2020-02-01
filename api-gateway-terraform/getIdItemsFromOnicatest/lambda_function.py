import json
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('onicaTest')

def lambda_handler(event, context):
    id = []
    item = []
    try:
        id = event['idno']
        test = int(id)
        if isinstance(test, int):
            response = table.get_item(
            Key={
                'id': id
                }
            )
            item.append(response['Item'])
            print(item)
            return item
    except:
        return ("something went wrong")