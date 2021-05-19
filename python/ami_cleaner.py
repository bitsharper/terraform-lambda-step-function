import os
import json
import boto3
from aws_lambda_powertools import Logger
from botocore.endpoint import convert_to_response_dict
from botocore.exceptions import ClientError

logger = Logger()

def lambda_handler(event,context): 
    ami_ids_list = None
    snapshot_ids_list = []
    failed_ami_ids =[]

    logger.info(event)

    ami_ids_list = event['ami_ids'].replace(" ", "").split(',')
    
    for id in ami_ids_list:
            print("Getting details for %s" % id)
            ami_details = get_ami_details(id)

            if ami_details != None and len(ami_details['Images']) > 0 :
                snapshot_ids_list.append(ami_details['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId'])
                deregister_ami(id)
            else:
                failed_ami_ids.append(id)

    for snapshot in snapshot_ids_list:
        delete_ami_snapshot(snapshot)

def deregister_ami(id: str):
    try:
        client = boto3.client('ec2')
        logger.info('Deregistring AMI: %s' % id)
        response = client.deregister_image(
            ImageId = id
        )
        return response
    except ClientError as error:
        logger.warning(error)

def delete_ami_snapshot(id: str):
    try:
        client = boto3.client('ec2')
        logger.info('Deleting snapshot: %s' % id)
        response = client.delete_snapshot(
            SnapshotId=id
        )
        return response    
    except ClientError as error:
        logger.warning(error)

def get_ami_details(id: str):
    try:    
        client = boto3.client('ec2')
        response = client.describe_images(ImageIds=[id])
        return response
    except ClientError as error:
        if error.response['Error']['Code'] == 'InvalidAMIID.NotFound':
            logger.warning('AMI %s Not Found. The specified AMI does not exist.' % id )
        elif error.response['Error']['Code'] == 'InvalidAMIID.Malformed':
            logger.warning('AMI %s The specified AMI ID is malformed. Invalid AMI Id.' % id )
        else:
            logger.warning(error) 
