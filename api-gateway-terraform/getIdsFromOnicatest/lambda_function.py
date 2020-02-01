import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('onicaTest')

def lambda_handler(event, context):
    response = table.scan(ProjectionExpression='id')
    id = []
    for i in response['Items']:
        id.append(int(i['id']))
    id.sort()
    result = []
    for j in id:
        response = table.query(
            KeyConditionExpression=Key('id').eq(str(j))
        )
        result.append(response['Items'])
    print(result)
    return result