import os
import json
import boto3
from logging import Filter
from aws_lambda_powertools import Logger
from botocore.endpoint import convert_to_response_dict

logger = Logger()

def lambda_handler(event, context): 
    logger.info('Event input:')
    logger.info(event)
    logger.info('Context')
    ami_id = event['ami_id']
    snapshot_id = [get_ami_snapshot_id(ami_id)]
    failed_amis = []
    failed_snapshots = []

    logger.info('Deregistring AMI: {ami_id}.')
    deregister_ami(ami_id)
    logger.info('Deleting snapshot: {snapshot_id}')
    delete_ami_snapshot(snapshot_id[0])


def get_ami_snapshot_id(id: str):
    client = boto3.client('ec2')
    response = client.describe_images(
        ImageIds =[id]
    )
    return response['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId']

def get_snapshot_details(ids: list):
    client = boto3.client('ec2')
    return client.describe_snapshots(SnapshotIds=ids)

def deregister_ami(id: str):
    client = boto3.client('ec2')
    response = client.deregister_image(
        ImageId = id
    )
    return response

def delete_ami_snapshot(id: str):
    client = boto3.client('ec2')
    response = client.delete_snapshot(
        SnapshotId=id
    )
    return response    
    
def get_ami_details(id: str):
    client = boto3.client('ec2')
    return client.describe_images(ImageIds=[id])['Images'][0]
