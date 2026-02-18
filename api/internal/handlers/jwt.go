package handlers

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/awslabs/aws-lambda-go-api-proxy/core"
)

// JWTClaims contains user information extracted from the JWT by API Gateway
type JWTClaims struct {
	Sub    string
	Email  string
	Groups []string
}

// localJWTClaimsKey is the context key used by InjectLocalJWTClaims middleware.
type localJWTClaimsKey struct{}

// ContextWithLocalJWTClaims returns a new context carrying the given claims.
// Used by the local-dev middleware to mirror API Gateway behaviour.
func ContextWithLocalJWTClaims(ctx context.Context, claims *JWTClaims) context.Context {
	return context.WithValue(ctx, localJWTClaimsKey{}, claims)
}

// ExtractJWTClaims extracts JWT claims from the API Gateway V2 request context
// payload (production) or from a local-dev context value (local/SAM).
func ExtractJWTClaims(r *http.Request) *JWTClaims {
	// Production / SAM path: claims come from requestContext.authorizer.jwt.claims
	if reqCtx, ok := core.GetAPIGatewayV2ContextFromContext(r.Context()); ok {
		if reqCtx.Authorizer != nil && reqCtx.Authorizer.JWT != nil {
			return claimsFromMap(reqCtx.Authorizer.JWT.Claims)
		}
	}

	// Local-dev path: claims injected by InjectLocalJWTClaims middleware
	if c, ok := r.Context().Value(localJWTClaimsKey{}).(*JWTClaims); ok {
		return c
	}

	return &JWTClaims{Groups: []string{}}
}

func claimsFromMap(m map[string]string) *JWTClaims {
	claims := &JWTClaims{
		Sub:    m["sub"],
		Email:  m["email"],
		Groups: []string{},
	}
	if raw, ok := m["cognito:groups"]; ok {
		var groups []string
		if err := json.Unmarshal([]byte(raw), &groups); err == nil {
			claims.Groups = groups
		}
	}
	return claims
}

// IsAdmin checks if the user has admin privileges
func (c *JWTClaims) IsAdmin() bool {
	for _, group := range c.Groups {
		if group == "admins" {
			return true
		}
	}
	return false
}

// IsUser checks if the user is in the users group
func (c *JWTClaims) IsUser() bool {
	for _, group := range c.Groups {
		if group == "users" {
			return true
		}
	}
	return false
}
