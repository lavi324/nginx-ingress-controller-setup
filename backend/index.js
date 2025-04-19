const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());

// MongoDB model without __v versioning
const userMetaSchema = new mongoose.Schema({
  ip: String,
  accessedAt: Date
}, { versionKey: false }); // ⛔ disables __v

const UserMeta = mongoose.model('UserMeta', userMetaSchema);

// Use environment variable for MongoDB connection
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

// Load time zone support
const moment = require('moment-timezone');

// Handler for fetching Apple stock data and logging IP
const fetchAppleStock = async (req, res) => {
  try {
    const apiKey = 'nrDn3xacOEf4dFkRzGzBu31Ef4wCxqL2'; // FMP API key
    const response = await axios.get(`https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=${apiKey}`);

    // Get and clean IP
    let ip = req.headers['x-forwarded-for']?.split(',')[0]?.trim()
      || req.connection?.remoteAddress
      || req.socket?.remoteAddress;

    if (ip?.startsWith('::ffff:')) {
      ip = ip.replace('::ffff:', '');
    }

    // Get timestamp in UTC
    const utcDate = new Date();

    // Convert to Israel time
    const israelTime = moment(utcDate).tz('Asia/Jerusalem').format('YYYY-MM-DD HH:mm:ss');

    // Save to DB
    const accessLog = new UserMeta({ ip, accessedAt: utcDate });
    await accessLog.save();

    // Send response with formatted timestamp
    res.json({
      stock: response.data[0],
      visitor: {
        ip,
        accessedAt: israelTime // Send Israel-local time to frontend
      }
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Failed to fetch Apple stock data' });
  }
};

// Serve both routes
app.get('/api/snp', fetchAppleStock);
app.get('/api/sp500', fetchAppleStock);  // Frontend compatibility

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
