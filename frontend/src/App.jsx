import { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [spData, setSpData] = useState(null);

  useEffect(() => {
    // Updated to call the backend using its external IP
    fetch('http://34.10.205.70:3001/api/sp500')
      .then(res => res.json())
      .then(data => setSpData(data))
      .catch(err => {
        console.error('Failed to fetch S&P 500 data:', err);
      });
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
          <p><strong>Your IP:</strong> {spData.visitor.ip}</p>
          <p><strong>Accessed at:</strong> {new Date(spData.visitor.accessedAt).toLocaleString()}</p>
        </>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default App;
