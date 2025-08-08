const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const s3 = new S3Client({});

const dataBucket = process.env.DataBucket;

async function getData(key) {
    let res;
    try {
        res = await s3.send(new GetObjectCommand({
            Bucket: dataBucket,
            Key: key,
        }));
    } catch (e) {
        console.error("Error getting S3 object:", e);
        throw new Error(`No such key: ${key}`);
    }
    console.log("Res:", res);

    const body = await res.Body.transformToString();

    return JSON.parse(body);
}

async function putData(key, data) {
    return s3.send(new PutObjectCommand({
        Bucket: dataBucket,
        Key: key,
        Body: JSON.stringify(data),
    }));
}

async function swapData(key) {
    const data = await getData(key);

    if (!data.ConversationAnalytics || !data.ConversationAnalytics.SpeakerLabels || data.ConversationAnalytics.SpeakerLabels.length < 2) {
        throw new Error("Invalid data structure: missing speaker labels");
    }

    const a = data.ConversationAnalytics.SpeakerLabels[0].DisplayText;
    const b = data.ConversationAnalytics.SpeakerLabels[1].DisplayText;

    data.ConversationAnalytics.SpeakerLabels[0].DisplayText = b;
    data.ConversationAnalytics.SpeakerLabels[1].DisplayText = a;

    return putData(key, data);
}

exports.handler = async function (event, context) {
    console.log("Event:", JSON.stringify(event, null, 4));

    try {
        const body = JSON.parse(event.body || '{}');
        const key = body.key;

        if (!key) {
            return {
                statusCode: 400,
                headers: {
                    "access-control-allow-origin": "*",
                    "access-control-allow-headers": "Content-Type,Authorization",
                    "access-control-allow-methods": "OPTIONS,POST",
                },
                body: JSON.stringify({
                    error: "Missing key parameter",
                }),
            };
        }

        await swapData(key);

        return {
            statusCode: 200,
            headers: {
                "access-control-allow-origin": "*",
                "access-control-allow-headers": "Content-Type,Authorization",
                "access-control-allow-methods": "OPTIONS,POST",
            },
            body: JSON.stringify({
                success: true,
            }),
        };
    } catch (error) {
        console.error("Error in swap handler:", error);
        return {
            statusCode: 500,
            headers: {
                "access-control-allow-origin": "*",
                "access-control-allow-headers": "Content-Type,Authorization",
                "access-control-allow-methods": "OPTIONS,POST",
            },
            body: JSON.stringify({
                error: "Internal server error",
                message: error.message,
            }),
        };
    }
};
