const { DynamoDBClient, QueryCommand } = require("@aws-sdk/client-dynamodb");
const ddb = new DynamoDBClient({});
const {
  withQueryStringValidation,
  searchSchema,
  response,
} = require("./validation");

const tableName = process.env.TableName;

function makeQuery(key, filter, filter_values) {
  let expression = "GSI1PK = :gsi1pk";
  let values = {
    ":gsi1pk": {
      S: key,
    },
  };

  if (filter != null) {
    expression += ` AND ${filter}`;

    if (filter_values != null) {
      values = { ...values, ...filter_values };
    }
  }

  return {
    TableName: tableName,
    IndexName: "GSI1",
    ScanIndexForward: false,
    KeyConditionExpression: expression,
    ExpressionAttributeValues: values,
  };
}

const handler = async function (event, context) {
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

  let queries = [];

  let params = event.queryStringParameters || {};

  if ("timestampFrom" in params) {
    if ("timestampTo" in params) {
      queries.push(
        makeQuery("call", "GSI1SK BETWEEN :start AND :end", {
          ":start": {
            S: params.timestampFrom,
          },
          ":end": {
            S: params.timestampTo,
          },
        })
      );
    } else {
      queries.push(
        makeQuery("call", "GSI1SK >= :start", {
          ":start": {
            S: params.timestampFrom,
          },
        })
      );
    }
  } else if ("timestampTo" in params) {
    queries.push(
      makeQuery("call", "GSI1SK <= :end", {
        ":end": {
          S: params.timestampTo,
        },
      })
    );
  }

  if (
    "sentimentWho" in params &&
    "sentimentWhat" in params &&
    "sentimentDirection" in params
  ) {
    const who = params.sentimentWho == "caller" ? "caller" : "agent";
    const what = params.sentimentWhat == "average" ? "average" : "trend";
    const query =
      params.sentimentDirection == "positive" ? "GSI1SK >= :zero" : "GSI1SK < :zero";

    queries.push(
      makeQuery(`sentiment#${who}#${what}`, query, {
        ":zero": {
          S: "0",
        },
      })
    );
  }

  // For language/entity search, get all calls if no other queries exist
  if (("entity" in params || "language" in params) && queries.length === 0) {
    queries.push(makeQuery("call"));
  }

  if("jobName" in params) {
    const query = makeQuery("call");
    query.FilterExpression = "contains(#col_name, :col_value)";

    let values = {
      ":col_value": {
        S: params.jobName,
      },
    };

    query.ExpressionAttributeValues = { ...query.ExpressionAttributeValues, ...values };

    query.ExpressionAttributeNames = {
      "#col_name": "Data"
    };

    queries.push(query);
  }

  if (queries.length == 0) {
    queries.push(makeQuery("call"));
  }

  console.log("Queries:", JSON.stringify(queries, null, 4));

  let promises = queries.map((query) => {
    return ddb.send(new QueryCommand(query));
  });

  let results = [];
  try {
    results = await Promise.all(promises);
  } catch (e) {
    throw e;
  }
  console.log("Results:", results);

  // Combine all results and deduplicate by PK
  let allItems = [];
  let seenPKs = new Set();
  
  results.forEach((result, index) => {
    console.log(`Query ${index} returned ${result.Items?.length || 0} items`);
    if (result.Items) {
      result.Items.forEach(item => {
        const pk = item.PKJobId?.S;
        if (pk && !seenPKs.has(pk)) {
          seenPKs.add(pk);
          allItems.push(item);
        }
      });
    }
  });

  console.log("Combined items before parsing:", allItems.length);
  
  let body = allItems.map((item) => {
    if (item.Data && item.Data.S) {
      try {
        const parsed = JSON.parse(item.Data.S);
        return parsed;
      } catch (e) {
        return null;
      }
    }
    return null;
  }).filter(item => item !== null);
  
  // Apply client-side filtering
  if ("language" in params) {
    console.log(`Filtering for language: ${params.language}`);
    console.log(`Items before filter: ${body.length}`);
    if (body.length > 0) {
      console.log(`Sample item lang: ${body[0].lang}`);
    }
    body = body.filter(item => item.lang && item.lang.includes(params.language));
    console.log(`Items after filter: ${body.length}`);
  }
  
  if ("entity" in params) {
    // This would need actual entity data in the call records
    // For now, just return all results
  }
  
  console.log("Final body length:", body.length);
  if (body.length > 0) {
    console.log("Returning search results:", body.map(item => item.jobName || 'No jobName'));
  } else {
    console.log("No results found after filtering");
  }

  return response(200, body, {
    "access-control-allow-methods": "OPTIONS,GET",
  });
};

exports.handler = withQueryStringValidation(handler, searchSchema);