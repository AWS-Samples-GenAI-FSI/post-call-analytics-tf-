"""
Lambda function triggered when files are written to S3 output bucket parsedFiles/ folder.
Creates DynamoDB UI records from processed JSON files.
"""
import boto3
import json
import os
import time
from urllib.parse import unquote_plus

def lambda_handler(event, context):
    """
    Process S3 events and create DynamoDB UI records
    """
    
    dynamodb = boto3.client('dynamodb')
    s3 = boto3.client('s3')
    
    table_name = os.environ['TableName']
    
    for record in event['Records']:
        # Get bucket and key from S3 event
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        
        # Only process files in parsedFiles/ folder
        if not key.startswith('parsedFiles/'):
            continue
            
        print(f"Processing file: {key}")
        
        try:
            # Read the processed JSON file
            response = s3.get_object(Bucket=bucket, Key=key)
            file_content = response['Body'].read().decode('utf-8')
            call_data = json.loads(file_content)
            
            # Extract job name from filename
            job_name = key.split('/')[-1].replace('.json', '')
            
            # Create rich UI record data from processed JSON
            timestamp = int(time.time() * 1000)
            
            # Extract metadata from processed call data
            conv_analytics = call_data.get('ConversationAnalytics', {})
            agent = conv_analytics.get('Agent', '')
            
            # Fix Duration extraction
            duration_raw = conv_analytics.get('Duration', '0')
            try:
                duration = float(duration_raw) if duration_raw else 0
                duration_str = f"{int(duration//60)}:{int(duration%60):02d}" if duration > 0 else "0:00"
            except (ValueError, TypeError):
                duration_str = "0:00"
                duration = 0
            
            language = conv_analytics.get('LanguageCode', '')
            
            # Fix sentiment extraction
            sentiment_trends = conv_analytics.get('SentimentTrends', {})
            cust_sentiment = 'n/a'
            if sentiment_trends:
                # Get spk_0 (usually customer)
                spk_0_data = sentiment_trends.get('spk_0', {})
                if isinstance(spk_0_data, dict) and 'SentimentScore' in spk_0_data:
                    score = float(spk_0_data['SentimentScore'])
                    cust_sentiment = 'Positive' if score > 0.1 else 'Negative' if score < -0.1 else 'Neutral'
            
            # Extract summary with fallback to action items
            summary = ''
            summary_data = conv_analytics.get('Summary', {})
            if isinstance(summary_data, dict) and 'Summary' in summary_data:
                summary_text = summary_data['Summary']
                if summary_text and 'error' not in summary_text.lower():
                    summary = summary_text[:100] + '...' if len(summary_text) > 100 else summary_text
            
            # Fallback to action items if no summary
            if not summary:
                action_items = conv_analytics.get('ActionItemsDetected', [])
                if action_items and len(action_items) > 0:
                    summary = action_items[0].get('Text', '')[:100] + '...' if len(action_items[0].get('Text', '')) > 100 else action_items[0].get('Text', '')
            
            # Extract issues/topics
            issues = conv_analytics.get('IssuesDetected', [])
            topic = issues[0]['Text'][:50] + '...' if issues and len(issues) > 0 else ''
            
            # Extract outcomes/resolution
            outcomes = conv_analytics.get('OutcomesDetected', [])
            resolved = 'Yes' if outcomes and len(outcomes) > 0 else 'No'
            
            # Extract product from CustomEntities
            custom_entities = conv_analytics.get('CustomEntities', [])
            product = ''
            for entity in custom_entities:
                if entity.get('Name') == 'COMMERCIAL_ITEM' and entity.get('Values'):
                    product = entity['Values'][0][:30]
                    break
            if not product:
                for entity in custom_entities:
                    if entity.get('Name') == 'ORGANIZATION' and entity.get('Values'):
                        product = entity['Values'][0][:30]
                        break
            
            # Get sentiment score as number
            sentiment_score = 0.0
            if sentiment_trends and 'spk_0' in sentiment_trends:
                spk_0_data = sentiment_trends['spk_0']
                if 'SentimentScore' in spk_0_data:
                    sentiment_score = float(spk_0_data['SentimentScore'])
            
            ui_data = {
                "key": key,
                "jobName": job_name,
                "timestamp": timestamp,
                "status": "Done",
                "agent": agent,
                "duration": int(duration),
                "lang": language,
                "callerSentimentScore": sentiment_score,
                "summary_summary": summary,
                "summary_resolved": resolved,
                "summary_topic": topic,
                "summary_product": product
            }
            
            # Create DynamoDB record
            call_id = f"call#{key}"
            
            dynamodb.put_item(
                TableName=table_name,
                Item={
                    'PKJobId': {'S': call_id},
                    'SKApiMode': {'S': 'call'},
                    'GSI1PK': {'S': 'call'},
                    'GSI1SK': {'S': str(timestamp)},
                    'TK': {'N': str(timestamp)},
                    'Data': {'S': json.dumps(ui_data)}
                }
            )
            
            print(f"Created UI record for: {job_name}")
            
        except Exception as e:
            print(f"Error processing {key}: {str(e)}")
            continue
    
    return {'statusCode': 200}