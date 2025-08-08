const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const s3 = new S3Client({});

const dataBucket = process.env.DataBucket;
const audioBucket = process.env.AudioBucket;

async function getData(key) {
    let res;
    try {
        console.log(`Attempting to get object: ${key} from bucket: ${dataBucket}`);
        res = await s3.send(new GetObjectCommand({
            Bucket: dataBucket,
            Key: key,
        }));
    } catch (e) {
        console.error(`Error getting object ${key}:`, e);
        return {
            statusCode: 404,
            body: JSON.stringify({ error: `No such key: ${key}`, details: e.message }),
        };
    }
    
    let data;
    try {
        const bodyString = await res.Body.transformToString();
        data = JSON.parse(bodyString);
        console.log("Successfully parsed JSON data");
    } catch (e) {
        console.error("Error parsing JSON:", e);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Invalid JSON in stored file", details: e.message }),
        };
    }

    try {
        const jobInfo = data.ConversationAnalytics.SourceInformation[0].TranscribeJobInfo;

        // Create presigned URL for the audio content if it exists
        if (jobInfo.MediaFileUri) {
            const audioKey = jobInfo.MediaFileUri.replace(/^s3:\/\/[^\/]+\//, "");
            jobInfo.MediaFileUri = await getSignedUrl(s3, new GetObjectCommand({
                Bucket: audioBucket,
                Key: audioKey,
            }), { expiresIn: 12 * 60 * 60 });
        }

        if (data.ConversationAnalytics?.CombinedAnalyticsGraph) {
            const graphKey = data.ConversationAnalytics.CombinedAnalyticsGraph.replace(/^s3:\/\/[^\/]+\//, "");
            data.ConversationAnalytics.CombinedAnalyticsGraph = await getSignedUrl(s3, new GetObjectCommand({
                Bucket: dataBucket,
                Key: graphKey,
            }), { expiresIn: 12 * 60 * 60 });
        }

        return JSON.stringify(data);
    } catch (e) {
        console.error("Error processing data:", e);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Error processing call data", details: e.message }),
        };
    }
}

exports.handler = async function (event, context) {
    console.log("Event:", JSON.stringify(event, null, 4));

    const key = event.queryStringParameters?.key;
    if (!key) {
        return {
            statusCode: 400,
            headers: {
                "access-control-allow-origin": "*",
                "access-control-allow-headers": "Content-Type,Authorization",
                "access-control-allow-methods": "OPTIONS,GET",
            },
            body: JSON.stringify({ error: "Missing key parameter" }),
        };
    }

    const result = await getData(key);
    
    // Check if getData returned an error response
    if (typeof result === 'object' && result.statusCode) {
        return {
            statusCode: result.statusCode,
            headers: {
                "access-control-allow-origin": "*",
                "access-control-allow-headers": "Content-Type,Authorization",
                "access-control-allow-methods": "OPTIONS,GET",
            },
            body: result.body,
        };
    }

    return {
        statusCode: 200,
        headers: {
            "access-control-allow-origin": "*",
            "access-control-allow-headers": "Content-Type,Authorization",
            "access-control-allow-methods": "OPTIONS,GET",
        },
        body: result,
    };
};
