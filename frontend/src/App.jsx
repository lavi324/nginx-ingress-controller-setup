import { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [spData, setSpData] = useState(null);
  const [clientIp, setClientIp] = useState(null);

  useEffect(() => {
    // Step 1: Get public IP from client side
    fetch('https://api.ipify.org?format=json')
      .then(res => res.json())
      .then(data => {
        setClientIp(data.ip);
        return fetch('http://34.10.205.70:3001/api/sp500', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ ip: data.ip }) // send IP to backend
        });
      })
      .then(res => res.json())
      .then(data => setSpData(data))
      .catch(err => console.error('Error fetching data:', err));
  }, []);

  return (
    <div style={{ padding: 50, fontFamily: 'sans-serif', textAlign: 'center' }}>
      <h1>S&P 500 Index</h1>
      {spData ? (
        <>
          <h2>{spData.stock.name} ({spData.stock.symbol})</h2>
          <p>Price: ${spData.stock.price}</p>
          <p>Change: {spData.stock.change} ({spData.stock.changesPercentage}%)</p>
          <hr />
          <p><strong>Your Public IP:</strong> {spData.visitor.ip}</p>
          <p><strong>Accessed at:</strong> {spData.visitor.accessedAt}</p>
        </>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default App;

