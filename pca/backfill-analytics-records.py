"""
This utility script backfills existing DynamoDB records with new fields to ensure
compatibility with updated post call analytics UI.

Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
"""
import boto3
import json
import time
import argparse
import pcaconfiguration as cf

def lambda_handler(event, context):
    """
    Lambda function entrypoint (can also be run as standalone script)
    """
    # Load our configuration data
    cf.loadConfiguration()
    table_name = cf.appConfig[cf.CONF_DYNAMODB_TABLE_NAME]
    
    # Initialize DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    
    # Scan table for call records
    scan_kwargs = {
        'FilterExpression': 'begins_with(PKJobId, :pk_prefix) AND SKApiMode = :sk_value',
        'ExpressionAttributeValues': {
            ':pk_prefix': 'call#',
            ':sk_value': 'call'
        }
    }
    
    items_updated = 0
    items_processed = 0
    
    print(f"Starting backfill of call analytics records in table {table_name}")
    
    done = False
    start_key = None
    while not done:
        if start_key:
            scan_kwargs['ExclusiveStartKey'] = start_key
        
        response = table.scan(**scan_kwargs)
        items = response.get('Items', [])
        
        for item in items:
            items_processed += 1
            
            if items_processed % 100 == 0:
                print(f"Processed {items_processed} items, updated {items_updated} so far")
            
            pk_job_id = item['PKJobId']
            sk_api_mode = item['SKApiMode']
            data_json = json.loads(item['Data'])
            
            # Flag to track if we need to update this item
            needs_update = False
            
            # Add callerSentiment text if needed
            if 'callerSentimentScore' in data_json and 'callerSentiment' not in data_json:
                score = data_json.get('callerSentimentScore', 0)
                if score > 0.1:
                    data_json['callerSentiment'] = 'Positive'
                elif score < -0.1:
                    data_json['callerSentiment'] = 'Negative'
                else:
                    data_json['callerSentiment'] = 'Neutral'
                needs_update = True
            
            # Add formatted duration string if needed
            if 'duration' in data_json and 'duration_str' not in data_json:
                duration_secs = data_json.get('duration', 0)
                data_json['duration_str'] = f"{int(duration_secs//60)}:{int(duration_secs%60):02d}" if duration_secs > 0 else "0:00"
                needs_update = True
            
            # Update the record if changes were made
            if needs_update:
                agent = data_json.get('agent', '')
                cust_sentiment = data_json.get('callerSentiment', 'neutral')
                timestamp = int(item.get('TK', time.time() * 1000))
                
                # Update the item with additional GSIs
                try:
                    table.update_item(
                        Key={
                            'PKJobId': pk_job_id,
                            'SKApiMode': sk_api_mode
                        },
                        UpdateExpression='SET #data = :data, GSI2PK = :gsi2pk, GSI2SK = :gsi2sk, GSI3PK = :gsi3pk, GSI3SK = :gsi3sk',
                        ExpressionAttributeNames={
                            '#data': 'Data'
                        },
                        ExpressionAttributeValues={
                            ':data': json.dumps(data_json),
                            ':gsi2pk': f"agent#{agent}" if agent else "agent#unknown",
                            ':gsi2sk': str(timestamp),
                            ':gsi3pk': f"sentiment#{cust_sentiment.lower()}" if cust_sentiment != "n/a" else "sentiment#neutral",
                            ':gsi3sk': str(timestamp)
                        }
                    )
                    items_updated += 1
                except Exception as e:
                    print(f"Error updating item {pk_job_id}: {str(e)}")
        
        start_key = response.get('LastEvaluatedKey', None)
        done = start_key is None
    
    print(f"Backfill complete. Processed {items_processed} items, updated {items_updated} items.")
    return {
        'processed': items_processed,
        'updated': items_updated
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Backfill analytics records with new fields')
    parser.add_argument('--profile', type=str, help='AWS profile name')
    parser.add_argument('--region', type=str, help='AWS region name')
    
    args = parser.parse_args()
    
    # If profile specified, use session
    if args.profile:
        session = boto3.Session(profile_name=args.profile, region_name=args.region)
        boto3.setup_default_session(profile_name=args.profile, region_name=args.region)
    
    lambda_handler({}, None)
