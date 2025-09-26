const express = require('express');
const mongoose = require('mongoose');
const cookieParser = require('cookie-parser');
const csurf = require('csurf');
const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');

const app = express();
const port = process.env.PORT || 3000;

const secretName = process.env.MONGODB_SECRET_NAME || 'prod/mongodb_uri';
const region = process.env.AWS_REGION || 'us-east-1';

const client = new SSMClient({ region });

async function getSecretValue(secretName) {
  try {
    const command = new GetParameterCommand({ Name: secretName, WithDecryption: true });
    const data = await client.send(command);
    return data.Parameter.Value;
  } catch (err) {
    console.error('Error retrieving parameter:', err);
    throw err;
  }
}

async function startServer() {
  try {
    const mongoUri = await getSecretValue(secretName);

    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Connected to MongoDB');

    // Basic middleware
    app.use(express.json());
    app.use(cookieParser());

    // Add CSRF protection middleware
    app.use(csurf({ cookie: true }));

    // Basic route
    app.get('/', (req, res) => {
      res.json({ message: 'Secure Microservice is running' });
    });

    // Start server
    app.listen(port, () => {
      console.log(`Server listening on port ${port}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

startServer();
