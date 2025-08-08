// Configuration will be dynamically generated during build
window.appConfig = {
  apiGateway: {
    REGION: 'us-east-1',
    URL: 'https://api.example.com'
  },
  cognito: {
    REGION: 'us-east-1',
    USER_POOL_ID: 'us-east-1_example',
    APP_CLIENT_ID: 'example123',
    IDENTITY_POOL_ID: '',
    DOMAIN: 'https://example.auth.us-east-1.amazoncognito.com'
  },
  s3: {
    REGION: 'us-east-1',
    BUCKET: 'example-bucket'
  }
};