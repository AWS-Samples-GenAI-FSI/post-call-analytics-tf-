"""
This python function is part of the main processing workflow.  It performs any final processing steps required
when the main processing has completed, along with any additional optional processing carried out by the
telephony-specific Contract Trace Record handling

Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
"""
import boto3
import json
import pcaconfiguration as cf


def lambda_handler(event, context):
    """
    Lambda function entrypoint
    """

    # Load our configuration data
    cf.loadConfiguration()
    results_bucket = cf.appConfig[cf.CONF_S3BUCKET_OUTPUT]

    # This function just has to move the interim results file to the full results file
    s3_resource = boto3.resource("s3")
    dest_key = cf.appConfig[cf.CONF_PREFIX_PARSED_RESULTS] + "/" + event["interimResultsFile"].split("/")[-1]
    copy_source = {
        'Bucket': results_bucket,
        'Key': event["interimResultsFile"]
    }
    s3_resource.meta.client.copy(copy_source, results_bucket, dest_key)

    # Then delete the interim file if we're not debugging
    if "debug" not in event:
        s3_client = boto3.client("s3")
        s3_client.delete_object(Bucket=results_bucket, Key=event["interimResultsFile"])

    # Write final record to DynamoDB for UI display
    try:
        import time
        import pcaresults
        ddb_client = boto3.client("dynamodb")
        
        # Load the processed results to extract metadata
        pca_results = pcaresults.PCAResults()
        pca_results.read_results_from_s3(results_bucket, dest_key)
        
        # Extract metadata from processed results
        analytics = pca_results.get_conv_analytics()
        job_name = event.get("jobName", "unknown")
        timestamp = int(time.time() * 1000)
        
        # Extract rich metadata
        agent = analytics.agent if analytics.agent else ""
        duration_secs = analytics.duration
        duration_str = f"{int(duration_secs//60)}:{int(duration_secs%60):02d}" if duration_secs > 0 else "NaN:NaN"
        language_code = analytics.conversationLanguageCode if analytics.conversationLanguageCode else ""
        
        # Extract summary if available
        summary = ""
        if analytics.summary and isinstance(analytics.summary, dict):
            if "Summary" in analytics.summary:
                summary = analytics.summary["Summary"][:100] + "..." if len(analytics.summary["Summary"]) > 100 else analytics.summary["Summary"]
        
        # Extract sentiment
        cust_sentiment = "n/a"
        if analytics.sentiment_trends:
            # Get overall customer sentiment trend
            for speaker, trends in analytics.sentiment_trends.items():
                if "cust" in speaker.lower() or "customer" in speaker.lower():
                    if trends and len(trends) > 0:
                        avg_sentiment = sum(trends) / len(trends)
                        cust_sentiment = "Positive" if avg_sentiment > 0.1 else "Negative" if avg_sentiment < -0.1 else "Neutral"
                    break
        
        # Create rich data payload matching UI expectations
        data_json = {
            "key": dest_key,
            "jobName": job_name,
            "timestamp": timestamp,
            "status": "Done",
            "guid": analytics.guid if analytics.guid else "",
            "agent": agent,
            "customer": analytics.cust if analytics.cust else "",
            "queue": analytics.telephony["Genesys"]["queueIds"][0] if analytics.telephony and "Genesys" in analytics.telephony and "queueIds" in analytics.telephony["Genesys"] and analytics.telephony["Genesys"]["queueIds"] else "",
            "summary_resolved": "",
            "summary_topic": "",
            "summary_product": "",
            "summary_summary": summary,
            "callerSentiment": cust_sentiment,  # Add text representation of sentiment
            "callerSentimentScore": 0.0,  # Will be calculated from sentiment trends
            "callerSentimentChange": 0,   # Will be calculated from sentiment trends
            "lang": language_code,
            "duration": duration_secs,  # Keep as number for sorting
            "duration_str": duration_str  # Add formatted duration string
        }
        
        # Calculate customer sentiment score if available
        if analytics.sentiment_trends:
            for speaker, trends in analytics.sentiment_trends.items():
                if "cust" in speaker.lower() or "customer" in speaker.lower():
                    if trends and len(trends) > 0:
                        data_json["callerSentimentScore"] = sum(trends) / len(trends)
                        # Simple trend calculation (positive if improving, negative if declining)
                        if len(trends) > 1:
                            data_json["callerSentimentChange"] = 1 if trends[-1] > trends[0] else -1
                    break
        
        # Use a more consistent ID format
        call_id = f"call#{dest_key}"
        
        # Add additional indices for better query performance
        ddb_client.put_item(
            TableName=cf.appConfig[cf.CONF_DYNAMODB_TABLE_NAME],
            Item={
                'PKJobId': {'S': call_id},
                'SKApiMode': {'S': 'call'},
                'GSI1PK': {'S': 'call'},
                'GSI1SK': {'S': str(timestamp)},
                'GSI2PK': {'S': f"agent#{agent}"} if agent else {'S': "agent#unknown"},
                'GSI2SK': {'S': str(timestamp)},
                'GSI3PK': {'S': f"sentiment#{cust_sentiment.lower()}"} if cust_sentiment != "n/a" else {'S': "sentiment#neutral"},
                'GSI3SK': {'S': str(timestamp)},
                'TK': {'N': str(timestamp)},
                'Data': {'S': json.dumps(data_json)}
            }
        )
        print(f"Rich UI record created for job: {job_name} with agent: {agent}, duration: {duration_str}")
    except Exception as e:
        print(f"Failed to create UI record: {str(e)}")
        import traceback
        traceback.print_exc()

    return event


# Main entrypoint for testing
if __name__ == "__main__":
    # Test event
    test_event_analytics = {
        "bucket": "ak-cci-input",
        "key": "originalAudio/Card2_GUID_102_AGENT_AndrewK_DT_2022-03-22T12-23-49.wav",
        "inputType": "audio",
        "jobName": "Card2_GUID_102_AGENT_AndrewK_DT_2022-03-22T12-23-49.wav",
        "apiMode": "analytics",
        "transcribeStatus": "COMPLETED",
        "interimResultsFile": "interimResults/Card2_GUID_102_AGENT_AndrewK_DT_2022-03-22T12-23-49.wav.json"
    }
    test_event_stereo = {
        "bucket": "ak-cci-input",
        "key": "originalAudio/Auto3_GUID_003_AGENT_BobS_DT_2022-03-21T17-51-51.wav",
        "inputType": "audio",
        "jobName": "Auto3_GUID_003_AGENT_BobS_DT_2022-03-21T17-51-51.wav",
        "apiMode": "standard",
        "transcribeStatus": "COMPLETED",
        "interimResultsFile": "interimResults/redacted-Auto3_GUID_003_AGENT_BobS_DT_2022-03-21T17-51-51.wav.json"
    }
    test_event_mono = {
        "bucket": "ak-cci-input",
        "key": "originalAudio/Auto0_GUID_000_AGENT_ChrisL_DT_2022-03-19T06-01-22_Mono.wav",
        "inputType": "audio",
        "jobName": "Auto0_GUID_000_AGENT_ChrisL_DT_2022-03-19T06-01-22_Mono.wav",
        "apiMode": "standard",
        "transcribeStatus": "COMPLETED",
        "interimResultsFile": "interimResults/redacted-Auto0_GUID_000_AGENT_ChrisL_DT_2022-03-19T06-01-22_Mono.wav.json"
    }
    test_stream_tca = {
        "bucket": "ak-cci-input",
        "key": "originalTranscripts/TCA_GUID_3c7161f7-bebc-4951-9cfb-943af1d3a5f5_CUST_17034816544_AGENT_BabuS_2022-11-22T21-32-52.145Z.json",
        "inputType": "transcript",
        "jobName": "TCA_GUID_3c7161f7-bebc-4951-9cfb-943af1d3a5f5_CUST_17034816544_AGENT_BabuS_2022-11-22T21-32-52.145Z.json",
        "apiMode": "analytics",
        "transcribeStatus": "COMPLETED",
        "interimResultsFile": "interimResults/TCA_GUID_3c7161f7-bebc-4951-9cfb-943af1d3a5f5_CUST_17034816544_AGENT_BabuS_2022-11-22T21-32-52.145Z.json"
    }
    lambda_handler(test_event_analytics, "")
    lambda_handler(test_event_stereo, "")
    lambda_handler(test_event_mono, "")
    lambda_handler(test_stream_tca, "")
