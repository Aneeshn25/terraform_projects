from __future__ import print_function # Python 2/3 compatibility
import boto3
import json
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('onicaTest')

def lambda_handler(event, context):
    id = []
    item = []
    response = table.scan(ProjectionExpression='id')
    for i in response['Items']:
        id.append(int(i['id']))
    id.sort()
    latest_id=id[-1]
    new_id=latest_id+1
    Fname = event['Firstname']
    Lname = event['Lastname']
    print(new_id)
    try:
        response = table.put_item(
            Item = {
                "id": str(new_id),
                    "details": {
                      "firstName": Fname,
                      "lastName": Lname
                }
            }
        )
        item.append(response)
        if item:
            posted="Posted to dynamodb with id: "+str(new_id) 
        return posted
    except:
        return ("Couldn't post to dynamodb, something went wrong")