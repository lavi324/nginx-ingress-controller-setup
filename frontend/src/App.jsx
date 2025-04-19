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
          <h2>{spData.name} ({spData.symbol})</h2>
          <p>Price: ${spData.price}</p>
          <p>Change: {spData.change} ({spData.changesPercentage}%)</p>
        </>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default App;

