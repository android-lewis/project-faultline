package middleware

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"strings"
)

const jwtClaimHeaderPrefix = "X-Amzn-Requestcontext-Authorizer-Jwt-Claim-"

// InjectLocalJWTClaims decodes bearer JWT payload and mirrors API Gateway claim headers.
func InjectLocalJWTClaims(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			next.ServeHTTP(w, r)
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")
		parts := strings.Split(token, ".")
		if len(parts) < 2 {
			next.ServeHTTP(w, r)
			return
		}

		payload, err := base64.RawURLEncoding.DecodeString(parts[1])
		if err != nil {
			next.ServeHTTP(w, r)
			return
		}

		var claims map[string]any
		if err := json.Unmarshal(payload, &claims); err != nil {
			next.ServeHTTP(w, r)
			return
		}

		if sub, ok := claims["sub"].(string); ok && sub != "" {
			r.Header.Set(jwtClaimHeaderPrefix+"sub", sub)
		}
		if email, ok := claims["email"].(string); ok && email != "" {
			r.Header.Set(jwtClaimHeaderPrefix+"email", email)
		}
		if groupsHeader := groupsHeaderValue(claims["cognito:groups"]); groupsHeader != "" {
			r.Header.Set(jwtClaimHeaderPrefix+"cognito:groups", groupsHeader)
		}

		next.ServeHTTP(w, r)
	})
}

func groupsHeaderValue(raw any) string {
	switch groups := raw.(type) {
	case []any:
		parsed := make([]string, 0, len(groups))
		for _, g := range groups {
			gString, ok := g.(string)
			if !ok || gString == "" {
				continue
			}
			parsed = append(parsed, gString)
		}

		if len(parsed) == 0 {
			return ""
		}

		marshaled, err := json.Marshal(parsed)
		if err != nil {
			return ""
		}
		return string(marshaled)
	case string:
		if groups == "" {
			return ""
		}
		marshaled, err := json.Marshal([]string{groups})
		if err != nil {
			return ""
		}
		return string(marshaled)
	default:
		return ""
	}
}
