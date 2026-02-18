package middleware

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/android-lewis/project-faultline/internal/handlers"
)

// InjectLocalJWTClaims decodes bearer JWT payload and stores claims in the
// request context, mirroring how API Gateway populates requestContext.authorizer.jwt.claims.
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

		var raw map[string]any
		if err := json.Unmarshal(payload, &raw); err != nil {
			next.ServeHTTP(w, r)
			return
		}

		claims := &handlers.JWTClaims{Groups: []string{}}
		if sub, ok := raw["sub"].(string); ok {
			claims.Sub = sub
		}
		if email, ok := raw["email"].(string); ok {
			claims.Email = email
		}
		claims.Groups = parseGroups(raw["cognito:groups"])

		ctx := handlers.ContextWithLocalJWTClaims(r.Context(), claims)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func parseGroups(raw any) []string {
	switch groups := raw.(type) {
	case []any:
		parsed := make([]string, 0, len(groups))
		for _, g := range groups {
			if s, ok := g.(string); ok && s != "" {
				parsed = append(parsed, s)
			}
		}
		return parsed
	case string:
		if groups != "" {
			return []string{groups}
		}
	}
	return []string{}
}
