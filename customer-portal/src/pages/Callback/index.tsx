import { h } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { useLocation } from 'preact-iso';
import { authService } from '../../auth/auth-service';

export default function Callback() {
  const [error, setError] = useState<string | null>(null);
  const { route } = useLocation();

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        await authService.handleCallback();
        route('/', true);
      } catch (err) {
        console.error('Authentication callback error:', err);
        setError(err instanceof Error ? err.message : 'Authentication failed');
      }
    };

    handleAuthCallback();
  }, []);

  if (error) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <h1>Authentication Error</h1>
        <p style={{ color: 'red' }}>{error}</p>
        <a href="/">Return to Home</a>
      </div>
    );
  }

  return (
    <div style={{ padding: '2rem', textAlign: 'center' }}>
      <h1>Completing authentication...</h1>
    </div>
  );
}
