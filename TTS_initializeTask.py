import json
import os
from boto3 import client
# from base64 import b64decode
# from urllib import parse

# base64Decoder function is to be called if messages are sent encoded in base 64. 
#   This happens when the message is sent by HTML forms, but not necessarily
#   when sent with a Javascript fetch request
#
#def base64Decoder(message):
#    message = b64decode(message.encode('utf-8'))
#    message = message.decode('utf-8')
#    return message

# httpTextParser is called when the message payload is encoded in http escape characters
#   This happens when the message is sent by HTML forms, but not necessarily
#   when sent with a Javascript fetch request
#
#def httpTextParser(body: str)->str:         #Unescape http escape chars
#    parsed = body[5:]
#    parsed = parse.unquote(body)
#    parsed = parsed.replace('+',' ')        #Turn '+' into whitespace
#    return parsed

def lambda_handler(event, context):
    try:
        body=event['body']
    except:
        return {
            "statusCode": 400,
            "body": "ERROR: TTS payload not specified"
        }
    print(body)
#    message = httpTextParser(base64Decoder(body))
    message = str(body)
    if len(message.split()) > 50 or len(message) > 300:
        return {
            "statusCode": 413,
            "body": "Your message is too long. Try again"
        }
    
    polly_client = client('polly')
    
    response = polly_client.start_speech_synthesis_task(
        Engine='standard',
        LanguageCode='en-US',
        OutputFormat='mp3',
        OutputS3BucketName= os.environ['BucketName'],
        OutputS3KeyPrefix= os.environ['KeyPrefix'],
        Text=message,
        VoiceId='Amy'
    )
    response = response['SynthesisTask']
    taskId = response['TaskId']
    bucketKey = str(os.environ['KeyPrefix']+"."+taskId+".mp3")
    
    
    return json.dumps({
        "isBase64Encoded": False,
        "statusCode": 202,
        "headers": {"x-tts-bucketkey": bucketKey},
        "body": {"taskId": taskId}
    })