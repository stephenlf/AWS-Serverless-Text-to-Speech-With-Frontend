import json
from boto3 import client

def lambda_handler(event, context):
    print(event['headers'])
    try:
        taskID = event['headers']['x-tts-taskid']
    except:
        return {
            "statusCode": 400,
            "body": "ERROR: TaskID not specified in the x-tts-taskid header."
        }
    polly_client = client('polly')
    try:
        synthesis_task = polly_client.get_speech_synthesis_task(TaskId=taskID)
    except:
        return {
            "statusCode": 400,
            "body": "ERROR: Invalid Task ID."
        }
    synthesis_task = synthesis_task['SynthesisTask']
    
    command = synthesis_task['TaskStatus']
    if synthesis_task['TaskStatus'] == 'scheduled' or synthesis_task['TaskStatus'] == 'inProgress':
        return {
            'statusCode': 302,
            'body': 'Task scheduled'
        }
    elif synthesis_task['TaskStatus'] == 'completed':
        return {
            'statusCode': 200,
            'body': str(synthesis_task['OutputUri'])
        }
    elif synthesis_task['TaskStatus'] == 'failed':
        return {
            'statusCode': 503,
            'body': 'ERROR: Task failed'
        }
    else:
        return {
            'statusCode': 500,
            'body': 'ERROR: Task failed'
        }
