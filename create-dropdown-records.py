#!/usr/bin/env python3
"""
Script to create language and entity records for dropdown functionality
This reads existing call records and creates the necessary language and entity records
"""
import boto3
import json
import time
import pcaconfiguration as cf

def create_dropdown_records():
    """Create language and entity records from existing call data"""
    
    # Load configuration
    cf.loadConfiguration()
    table_name = cf.appConfig[cf.CONF_DYNAMODB_TABLE_NAME]
    
    # Initialize DynamoDB
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    
    # Track unique languages and entities
    languages = set()
    entities = set()
    
    print(f"Scanning call records in table {table_name}")
    
    # Scan for call records
    scan_kwargs = {
        'FilterExpression': 'begins_with(PKJobId, :pk_prefix) AND SKApiMode = :sk_value',
        'ExpressionAttributeValues': {
            ':pk_prefix': 'call#',
            ':sk_value': 'call'
        }
    }
    
    done = False
    start_key = None
    items_processed = 0
    
    while not done:
        if start_key:
            scan_kwargs['ExclusiveStartKey'] = start_key
        
        response = table.scan(**scan_kwargs)
        items = response.get('Items', [])
        
        for item in items:
            items_processed += 1
            
            try:
                data_json = json.loads(item['Data'])
                
                # Extract language
                if 'lang' in data_json and data_json['lang']:
                    languages.add(data_json['lang'])
                
                # For now, add some common entity types that might be detected
                # In a real implementation, you'd extract these from the actual call analysis
                common_entities = ['PERSON', 'LOCATION', 'ORGANIZATION', 'DATE', 'PHONE_NUMBER', 'EMAIL']
                for entity in common_entities:
                    entities.add(entity)
                    
            except Exception as e:
                print(f"Error processing item: {str(e)}")
        
        start_key = response.get('LastEvaluatedKey', None)
        done = start_key is None
    
    print(f"Processed {items_processed} call records")
    print(f"Found {len(languages)} unique languages: {list(languages)}")
    print(f"Will create {len(entities)} entity types: {list(entities)}")
    
    # Create language records
    for lang in languages:
        try:
            table.put_item(
                Item={
                    'PK': f'language#{lang}',
                    'SK': 'language',
                    'GSI1PK': 'language',
                    'GSI1SK': lang,
                    'Data': lang
                }
            )
            print(f"Created language record: {lang}")
        except Exception as e:
            print(f"Error creating language record for {lang}: {str(e)}")
    
    # Create entity records
    for entity in entities:
        try:
            table.put_item(
                Item={
                    'PK': f'entity#{entity}',
                    'SK': 'entity', 
                    'GSI1PK': 'entity',
                    'GSI1SK': entity,
                    'Data': entity
                }
            )
            print(f"Created entity record: {entity}")
        except Exception as e:
            print(f"Error creating entity record for {entity}: {str(e)}")
    
    print(f"Created {len(languages)} language records and {len(entities)} entity records")
    return {
        'languages_created': len(languages),
        'entities_created': len(entities)
    }

if __name__ == "__main__":
    create_dropdown_records()