import { h, Fragment, ComponentChildren } from 'preact';
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
        return;
      }
      setIsAuthenticated(true);
    };

    void checkAuth();
  }, []);

  if (isAuthenticated === null) {
    return h('div', null, 'Loading...');
  }

  return h(Fragment, null, children);
}
