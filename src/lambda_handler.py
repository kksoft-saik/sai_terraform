import json
import boto3

from botocore.client import ClientError
from datetime import datetime, timedelta, tzinfo

SOURCE_ARN="arn:aws:rds:ap-northeast-1:823263222252:cluster-snapshot:saidb-sn"
S3_BUCKET_NAME="saikous3"
IAM_ROLE_ARN="arn:aws:iam::823263222252:user/cuikang@kksoft.co.jp"
KMS_KEY_ID=aws_kms_key.a.id


rds = boto3.client('rds')
s3 = boto3.resource('s3')
client = boto3.client('rds')


def export_snapshot(prefix, instanceid):
    snapshots = rds.describe_db_snapshots(DBInstanceIdentifier=instanceid,SnapshotType='manual')['DBSnapshots']
    snapshots= sorted(snapshots , key=lambda x: x['SnapshotCreateTime'],reverse=True)
    snapshot = snapshots[0]  
    newsnapshotid = "-".join([prefix, datetime.now().strftime("%Y-%m-%d-%H-%M")])
    
    response = rds.start_export_task(
        ExportTaskIdentifier=export_task_identifier,
        SourceArn=SOURCE_ARN,
        S3BucketName=S3_BUCKET_NAME,
        IamRoleArn=IAM_ROLE_ARN,
        KmsKeyId=KMS_KEY_ID,
        S3Prefix=[sk],
        )
    return(response)

    
def lambda_handler(event, context):

    export_task_identifier="mysnapshot" + datetime.now().strftime("%Y%m%d%H%M%S")

    response = client.start_export_task(
        ExportTaskIdentifier=export_task_identifier,
        SourceArn=SOURCE_ARN,
        S3BucketName=S3_BUCKET_NAME,
        IamRoleArn=IAM_ROLE_ARN,
        KmsKeyId=KMS_KEY_ID,
    )
