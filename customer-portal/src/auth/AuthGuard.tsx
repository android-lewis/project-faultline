import { h, ComponentChildren } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { authService } from './auth-service';

interface AuthGuardProps {
  children: ComponentChildren;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);

  useEffect(() => {
    const checkAuth = async () => {
      const authenticated = await authService.isAuthenticated();
      if (!authenticated) {
        await authService.login();
      } else {
        setIsAuthenticated(true);
      }
    };

    checkAuth();
  }, []);

  if (isAuthenticated === null) {
    return <div>Loading...</div>;
  }

  return <>{children}</>;
}
