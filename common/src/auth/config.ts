import { UserManagerSettings } from 'oidc-client-ts';

const authority = import.meta.env.VITE_COGNITO_AUTHORITY;
const clientId = import.meta.env.VITE_COGNITO_CLIENT_ID;
const redirectUri = import.meta.env.VITE_COGNITO_REDIRECT_URI;
const postLogoutRedirectUri = import.meta.env.VITE_COGNITO_POST_LOGOUT_REDIRECT_URI;
const cognitoDomain = import.meta.env.VITE_COGNITO_DOMAIN;

if (!authority || !clientId || !redirectUri || !postLogoutRedirectUri || !cognitoDomain) {
  throw new Error(
    'Missing required environment variables. Ensure VITE_COGNITO_AUTHORITY, ' +
      'VITE_COGNITO_CLIENT_ID, VITE_COGNITO_REDIRECT_URI, VITE_COGNITO_POST_LOGOUT_REDIRECT_URI, ' +
      'and VITE_COGNITO_DOMAIN are set.'
  );
}

export const oidcConfig: UserManagerSettings = {
  authority,
  client_id: clientId,
  redirect_uri: redirectUri,
  post_logout_redirect_uri: postLogoutRedirectUri,
  response_type: 'code',
  scope: 'openid email profile',
  automaticSilentRenew: true,
  loadUserInfo: false,
  metadata: {
    issuer: authority,
    authorization_endpoint: `https://${cognitoDomain}/oauth2/authorize`,
    token_endpoint: `https://${cognitoDomain}/oauth2/token`,
    userinfo_endpoint: `https://${cognitoDomain}/oauth2/userInfo`,
    end_session_endpoint: `https://${cognitoDomain}/logout`,
    jwks_uri: `${authority}/.well-known/jwks.json`,
  },
};
