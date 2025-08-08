#!/usr/bin/env python3
"""
Script to add language and entity record creation to the post-processing Lambda function
This ensures dropdown menus are populated automatically during call processing
"""

import re

def add_dropdown_record_creation():
    """Add code to create language and entity records in post-processing function"""
    
    # Read the current post-processing function
    with open('pca/pca-aws-sf-post-processing.py', 'r') as f:
        content = f.read()
    
    # Find the location to insert the new code (after the main record creation)
    insert_point = content.find('print(f"Rich UI record created for job: {job_name}')
    if insert_point == -1:
        print("Could not find insertion point in post-processing function")
        return False
    
    # Move to end of that line
    insert_point = content.find('\n', insert_point) + 1
    
    # Code to add language and entity records
    additional_code = '''
        # Create language record for dropdown
        if language_code:
            try:
                ddb_client.put_item(
                    TableName=cf.appConfig[cf.CONF_DYNAMODB_TABLE_NAME],
                    Item={
                        'PK': {'S': f'language#{language_code}'},
                        'SK': {'S': 'language'},
                        'GSI1PK': {'S': 'language'},
                        'GSI1SK': {'S': language_code},
                        'Data': {'S': language_code}
                    }
                )
                print(f"Language record created: {language_code}")
            except Exception as e:
                print(f"Failed to create language record: {str(e)}")
        
        # Create entity records for dropdown (if entities are detected)
        try:
            if analytics.entities:
                for entity_type in set(entity.entity_type for entity in analytics.entities):
                    ddb_client.put_item(
                        TableName=cf.appConfig[cf.CONF_DYNAMODB_TABLE_NAME],
                        Item={
                            'PK': {'S': f'entity#{entity_type}'},
                            'SK': {'S': 'entity'},
                            'GSI1PK': {'S': 'entity'},
                            'GSI1SK': {'S': entity_type},
                            'Data': {'S': entity_type}
                        }
                    )
                print(f"Entity records created for detected types")
        except Exception as e:
            print(f"Failed to create entity records: {str(e)}")
'''
    
    # Insert the new code
    new_content = content[:insert_point] + additional_code + content[insert_point:]
    
    # Write back the modified content
    with open('pca/pca-aws-sf-post-processing.py', 'w') as f:
        f.write(new_content)
    
    print("✅ Added language and entity record creation to post-processing function")
    return True

if __name__ == "__main__":
    add_dropdown_record_creation()