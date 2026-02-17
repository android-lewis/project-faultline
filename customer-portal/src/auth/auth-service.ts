import { UserManager, User } from 'oidc-client-ts';
import { oidcConfig } from './config';

class AuthService {
  private userManager: UserManager;

  constructor() {
    this.userManager = new UserManager(oidcConfig);
  }

  async login(): Promise<void> {
    await this.userManager.signinRedirect();
  }

  async handleCallback(): Promise<User> {
    const user = await this.userManager.signinRedirectCallback();
    return user;
  }

  async logout(): Promise<void> {
    await this.userManager.signoutRedirect();
  }

  async getUser(): Promise<User | null> {
    return await this.userManager.getUser();
  }

  async getAccessToken(): Promise<string | null> {
    const user = await this.getUser();
    return user?.access_token || null;
  }

  async isAuthenticated(): Promise<boolean> {
    const user = await this.getUser();
    return !!user && !user.expired;
  }
}

export const authService = new AuthService();
