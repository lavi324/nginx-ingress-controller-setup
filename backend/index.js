const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const cors = require('cors');
const moment = require('moment-timezone');

const app = express();
app.use(cors());
app.set('trust proxy', true); // ✅ Trust the proxy to get the user's real public IP

// MongoDB schema (no __v)
const userMetaSchema = new mongoose.Schema({
  ip: String,
  accessedAt: Date
}, { versionKey: false }); // ✅ disables __v

const UserMeta = mongoose.model('UserMeta', userMetaSchema);

// MongoDB connection
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

// Main route handler
const fetchAppleStock = async (req, res) => {
  try {
    const apiKey = 'nrDn3xacOEf4dFkRzGzBu31Ef4wCxqL2';
    const response = await axios.get(`https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=${apiKey}`);

    // ✅ Get real public IP (after trust proxy is enabled)
    const ip = req.ip;

    // UTC date + conversion to Israel time
    const utcDate = new Date();
    const israelTime = moment(utcDate).tz('Asia/Jerusalem').format('YYYY-MM-DD HH:mm:ss');

    // Save to MongoDB
    const accessLog = new UserMeta({ ip, accessedAt: utcDate });
    await accessLog.save();

    // Response
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

// Routes
app.get('/api/snp', fetchAppleStock);
app.get('/api/sp500', fetchAppleStock); // compatibility route

// Start server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
