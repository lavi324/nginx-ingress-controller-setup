const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const cors = require('cors');
const moment = require('moment-timezone');

const app = express();
app.use(cors());
app.use(express.json()); // ✅ Parse JSON body
app.set('trust proxy', true);

// MongoDB schema (no __v)
const userMetaSchema = new mongoose.Schema({
  ip: String,
  accessedAt: Date
}, { versionKey: false });

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

// Route: POST to log IP + return stock data
app.post('/api/sp500', async (req, res) => {
  try {
    const { ip } = req.body;
    if (!ip) return res.status(400).json({ error: 'IP address missing from request' });

    const apiKey = 'nrDn3xacOEf4dFkRzGzBu31Ef4wCxqL2';
    const response = await axios.get(`https://financialmodelingprep.com/api/v3/quote/AAPL?apikey=${apiKey}`);

    const utcDate = new Date();
    const israelTime = moment(utcDate).tz('Asia/Jerusalem').format('YYYY-MM-DD HH:mm:ss');

    const accessLog = new UserMeta({ ip, accessedAt: utcDate });
    await accessLog.save();

    res.json({
      stock: response.data[0],
      visitor: {
        ip,
        accessedAt: israelTime
      }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Failed to fetch data or log IP' });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});

