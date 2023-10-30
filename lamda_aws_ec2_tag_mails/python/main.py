import boto3
import datetime
import os

today = datetime.date.today()
today_string = today.strftime('%Y-%m-%d')

AWS_REGION = os.environ['region']
tagname = "Name"
RECIPIENT = "pharoahpaul1.com"
SENDER = os.environ['fromAddress']

def lambda_handler(event, context):

    ec2 = boto3.resource('ec2', region_name=AWS_REGION)
    instances = ec2.instances.filter(
        Filters=[
            {
                'Name': 'tag:'+tagname,
                'Values': ['']
            }
        ]
    )

    volume_ids = []
    for i in instances.all():
        volume_ids.append(i.id)

    if volume_ids != []:
    
        SUBJECT = "Amazon EC2 Instance without tags - {}".format(AWS_REGION)

        BODY_TEXT = ("Amazon SES Test (Python)\r\n"
                    "This email was sent with Amazon SES using the "
                    "AWS SDK for Cloudnloud Tech Community (Boto)."
                    )
        # The HTML body of the email.
        BODY_HTML = """<html>
        <head></head>
        <body>
        <h1>Amazon EC2 Instance without tags</h1>
        <hr>
        <br>
        <br>
        <pre style="font:Freemono;font-size: 24px;"> Hi Team,

            I found the the instance without proper tags. Please take action against.

        Date {} - instance ids are {}


        Regards
        Security Team


        </pre>
        <p>This email was sent with
            <a href='https://aws.amazon.com/ses/'>Amazon SES</a></p>
        </body>
        </html>""".format(today_string,volume_ids)


        CHARSET = "UTF-8"

        client = boto3.client('ses', region_name=AWS_REGION)
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER
        )
        print(response['MessageId'])