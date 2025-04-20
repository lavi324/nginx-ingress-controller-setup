const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const cors = require('cors');
const moment = require('moment-timezone');

const app = express();
app.use(cors());

// Trust X-Forwarded-For header from the load balancer
app.set('trust proxy', true);

// MongoDB schema with no __v
const userMetaSchema = new mongoose.Schema({
  ip: String,
  accessedAt: String  // Store as string in local Israel time
}, { versionKey: false });

const UserMeta = mongoose.model('UserMeta', userMetaSchema);

// Connect to MongoDB
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/visitorDB';

mongoose.connect(mongoUri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  dbName: 'visitorDB',
}).then(() => {
  console.log('Connected to MongoDB');
}).catch((err) => {
  console.error('MongoDB connection error:', err.message);
});

// API route
const fetchAppleStock = async (req, res) => {
  try {
    const apiKey = 'nrDn3xacOEf4dFkRzGzBu31Ef4wCxqL2';
    const response = await axios.get(`https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=${apiKey}`);

    // Get real public IP from X-Forwarded-For header or fallback
    let ip = req.headers['x-forwarded-for']?.split(',')[0]?.trim()
      || req.connection?.remoteAddress
      || req.socket?.remoteAddress;

    if (ip?.startsWith('::ffff:')) {
      ip = ip.replace('::ffff:', '');
    }

    // Get current time in Israel time zone as string
    const israelTime = moment().tz('Asia/Jerusalem').format('YYYY-MM-DD HH:mm:ss');

    // Save to DB
    const accessLog = new UserMeta({ ip, accessedAt: israelTime });
    await accessLog.save();

    // Return data
    res.json({
      stock: response.data[0],
      visitor: {
        ip,
        accessedAt: israelTime
      }
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Failed to fetch Apple stock data' });
  }
};

app.get('/api/snp', fetchAppleStock);
app.get('/api/sp500', fetchAppleStock);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
