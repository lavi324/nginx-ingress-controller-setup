const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());

// MongoDB model for logging IP and timestamp
const UserMeta = mongoose.model('UserMeta', new mongoose.Schema({
  ip: String,
  accessedAt: Date
}));

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

// Shared handler for fetching S&P 500 data and logging IP
const fetchSP500 = async (req, res) => {
  try {
    const apiKey = 'nrDn3xacOEf4dFkRzGzBu31Ef4wCxqL2'; // FMP API key
    const response = await axios.get(`https://financialmodelingprep.com/api/v3/quote/%5EGSPC?apikey=${apiKey}`);
    
    const userIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    await new UserMeta({ ip: userIp, accessedAt: new Date() }).save();

    res.json(response.data[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Failed to fetch S&P 500 data' });
  }
};

// Serve both routes (you can remove one if unnecessary)
app.get('/api/snp', fetchSP500);
app.get('/api/sp500', fetchSP500);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
