import { useEffect, useState } from 'preact/hooks';
import { useLocation } from 'preact-iso';
import { authService } from '@project-faultline/common';

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

    void handleAuthCallback();
  }, [route]);

  if (error) {
    return (
      <div class="mx-auto w-full max-w-2xl rounded-xl border border-rose-200 bg-white p-8 text-center shadow-sm">
        <h1 class="mb-2 text-2xl font-semibold text-slate-900">Authentication Error</h1>
        <p class="mb-4 text-sm text-rose-700">{error}</p>
        <a class="text-sm font-medium text-slate-900 underline" href="/">
          Return to Dashboard
        </a>
      </div>
    );
  }

  return (
    <div class="mx-auto w-full max-w-2xl rounded-xl border border-slate-200 bg-white p-8 text-center shadow-sm">
      <h1 class="text-2xl font-semibold text-slate-900">Completing authentication...</h1>
    </div>
  );
}
