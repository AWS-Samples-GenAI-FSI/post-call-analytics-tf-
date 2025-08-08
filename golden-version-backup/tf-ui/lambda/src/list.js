const { DynamoDBClient, QueryCommand } = require("@aws-sdk/client-dynamodb");
const {
  listSchema,
  withQueryStringValidation,
  response,
} = require("./validation");

const ddb = new DynamoDBClient({});
const tableName = process.env.TableName;
const DEFAULT_COUNT = 100;

async function handler(event, context) {
  console.log(
    JSON.stringify(
      {
        event: event,
        context: context,
      },
      null,
      4
    )
  );

  let start = null;
  let count = DEFAULT_COUNT;

  if (event.queryStringParameters != null) {
    if (
      "startKey" in event.queryStringParameters &&
      "timestampFrom" in event.queryStringParameters
    ) {
      start = {
        PKJobId: {
          S: `call#${event.queryStringParameters.startKey}`,
        },
        SKApiMode: {
          S: "call",
        },
        GSI1PK: {
          S: "call",
        },
        GSI1SK: {
          S: event.queryStringParameters.timestampFrom,
        },
      };
    }

    if ("count" in event.queryStringParameters) {
      count = event.queryStringParameters.count;
    }
  }

  let query = {
    TableName: tableName,
    IndexName: "GSI1",
    ScanIndexForward: !("reverse" in (event?.queryStringParameters || {})),
    Limit: count,
    KeyConditionExpression: "GSI1PK = :gsi1pk",
    ExpressionAttributeValues: {
      ":gsi1pk": {
        S: "call",
      },
    },
  };
  
  if (start != null) {
    query.ExclusiveStartKey = start;
  }

  console.log("Query:", JSON.stringify(query, null, 2));
  
  let res;
  try {
    const command = new QueryCommand(query);
    res = await ddb.send(command);
  } catch (e) {
    console.error("DynamoDB Error:", e);
    return response(500, { error: "Database query failed" });
  }
  
  console.log(res);

  const body = {
    Records: res.Items ? res.Items.map((item) => {
      return JSON.parse(item.Data.S);
    }) : [],
  };

  if (res.LastEvaluatedKey) {
    body.StartKey = res.LastEvaluatedKey.PKJobId.S.replace('call#', '');
    body.timestampFrom = res.LastEvaluatedKey.GSI1SK.S;
  }

  return response(200, body, {
    "Access-Control-Allow-Methods": "OPTIONS,GET",
    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
  });
}

exports.handler = withQueryStringValidation(handler, listSchema);
