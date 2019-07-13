import boto3
import json
import logging
import os
import urllib.request

logger = logging.getLogger()
logger.setLevel(os.environ['log_level'])


def post_contact(message):
    # Secrets ManagerからSlack APIのトークン情報を取得
    secretsmanager = boto3.client(service_name='secretsmanager')
    secret_value = secretsmanager.get_secret_value(
        SecretId=os.environ['secrets_slack_api'])
    secrets = json.loads(secret_value['SecretString'])

    # リクエストの組み立て
    api_request = urllib.request.Request(
        'https://slack.com/api/chat.postMessage',
        data=json.dumps({
            'channel': secrets['contact_channel_id'],
            'text': message,
        }).encode('utf-8'),
        method='POST',
        headers={
            'Content-Type': 'application/json',
            'Authorization': 'Bearer {}'.format(secrets['access_token'])
        },
    )

    # APIにリクエスト
    with urllib.request.urlopen(api_request) as api_response:
        api_response_body_str = api_response.read().decode('utf-8')

    # 結果の確認
    api_response_body = json.loads(api_response_body_str)
    if api_response_body['ok']:
        # 成功
        logger.debug(api_response_body_str)

    else:
        # 失敗
        raise Exception(api_response_body_str)


def lambda_handler(event, context):
    try:
        logger.debug(json.dumps(event))
        body = json.loads(event['body'])

        post_contact(body['message'])

        return {
            'isBase64Encoded': False,
            'statusCode': 200,
            'headers': {},
            'body': json.dumps({})
        }
    except Exception as exception:
        logger.exception(exception)

        # 処理失敗時、SQSに送信
        sqs = boto3.client(service_name='sqs')
        sqs.send_message(
            QueueUrl=os.environ['dlq_url'],
            MessageBody=json.dumps(event))

        raise exception



