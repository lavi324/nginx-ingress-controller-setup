import { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [spData, setSpData] = useState(null);

  useEffect(() => {
    fetch('/api/snp')
      .then(res => res.json())
      .then(data => setSpData(data));
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

