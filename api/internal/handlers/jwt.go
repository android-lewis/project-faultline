package handlers

import (
	"encoding/json"
	"net/http"
	"strings"
)

// JWTClaims contains user information extracted from the JWT by API Gateway
type JWTClaims struct {
	Sub    string
	Email  string
	Groups []string
}

// ExtractJWTClaims extracts JWT claims from the API Gateway request context
func ExtractJWTClaims(r *http.Request) *JWTClaims {
	claims := &JWTClaims{
		Groups: []string{},
	}

	// HTTP API JWT authorizer passes claims in the X-Amzn-Requestcontext-Authorizer-Jwt-Claim-* headers
	// These are set by aws-lambda-go-api-proxy when it processes the Lambda event
	for name, values := range r.Header {
		lowerName := strings.ToLower(name)
		if len(values) == 0 {
			continue
		}

		if strings.HasPrefix(lowerName, "x-amzn-requestcontext-authorizer-jwt-claim-") {
			claimName := strings.TrimPrefix(lowerName, "x-amzn-requestcontext-authorizer-jwt-claim-")
			switch claimName {
			case "sub":
				claims.Sub = values[0]
			case "email":
				claims.Email = values[0]
			case "cognito:groups":
				var groups []string
				if err := json.Unmarshal([]byte(values[0]), &groups); err == nil {
					claims.Groups = groups
				}
			}
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
