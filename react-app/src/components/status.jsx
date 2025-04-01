import React, { useState, useEffect } from 'react';

const Status = () => {
  const [status, setStatus] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchStatus = async () => {
      try {
        const response = await fetch('http://localhost:3001/status');
        if (!response.ok) {
          throw new Error('Erro ao buscar status');
        }
        const data = await response.json();
        setStatus(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchStatus();
  }, []);

  if (loading) return <p>Carregando...</p>;
  if (error) return <p>Erro: {error}</p>;

  return (
    <div>
      <p>Status: {status.status}</p>
      <p>Mensagem: {status.message}</p>
      <p>Timestamp: {status.timestamp}</p>
    </div>
  );
};

export default Status;