const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());

const UserMeta = mongoose.model('UserMeta', new mongoose.Schema({
  ip: String,
  accessedAt: Date
}));

// Connect to MongoDB using Bitnami Helm chart (default MongoDB service name)
mongoose.connect('mongodb://mongodb:27017/visitorDB', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

app.get('/api/snp', async (req, res) => {
  try {
    const apiKey = 'nrDn3xacOEf4dFkRzGzBu31Ef4wCxqL2'; // ← FMP free API key
    const response = await axios.get(`https://financialmodelingprep.com/api/v3/quote/%5EGSPC?apikey=${apiKey}`);
    
    const userIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    await new UserMeta({ ip: userIp, accessedAt: new Date() }).save();

    res.json(response.data[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Failed to fetch S&P 500 data' });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
