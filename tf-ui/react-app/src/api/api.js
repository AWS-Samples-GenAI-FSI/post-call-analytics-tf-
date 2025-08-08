import * as auth from "./auth.js";

const config = window.pcaSettings;

function handleError(err) {
  if(err) console.error(err);
  throw err;
}

async function request(url, method, body) {
  const options = {
    method: method || "GET",
    headers: {
      Authorization: await auth.getToken(),
    },
  };

  if (body !== null) {
    options.body = JSON.stringify(body);
    options.headers["Content-Type"] = "application/json";
  }

  let response;
  try {
    console.debug("Request opts:", JSON.stringify(options, null, 4));
    response = await fetch(url, options);
  } catch (err) {
    return handleError(err);
  }

  console.debug("Response:", response);

  if (response.status === 403 || response.status === 401) {
    return auth.redirectToLogin("Unathenticated.");
  }

  if (response.status !== 200) {
    const errorText = await response.text();
    console.error(`API Error ${response.status}:`, errorText);
    return handleError(`API Error ${response.status}: ${errorText}`);
  }

  return response.json();
}

async function getRequest(resource, data) {
  const url = new URL(`${config.api.uri}/${resource}`);

  if (data != null) {
    for (const key in data) {
      url.searchParams.append(key, data[key]);
    }
  }

  return request(url.toString());
}

export async function get(key) {
  return getRequest("get", { key: key });
}

export async function head(key) {
  return getRequest("head", { key: key });
}

export async function search(query) {
  return getRequest("search", query);
}

export async function list(params) {
  // Filter out undefined values to prevent "undefined" in query string
  const cleanParams = params ? Object.fromEntries(
    Object.entries(params).filter(([_, value]) => value !== undefined)
  ) : null;
  return getRequest("list", cleanParams);
}

export async function swap(key) {
  return request(`${config.api.uri}/swap`, "POST", { key: key });
}

export async function entities(key) {
  return getRequest("entities");
}

export async function languages(key) {
  return getRequest("languages");
}

export async function genaiquery(filename, query) {
  return getRequest(`genaiquery`, {
    "filename": filename,
    "query": query
  } );
}

export async function genairefresh(filename) {
  return getRequest("genai/refreshsummary", {
    "filename": filename,
  } );
}

export async function presign(filename) {
  return getRequest("presign", {
    "filename": filename,
  } );
}
