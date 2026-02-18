package middleware

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/android-lewis/project-faultline/internal/handlers"
)

func TestInjectLocalJWTClaims_SetsClaimsInContext(t *testing.T) {
	token := jwtForTest(t, map[string]any{
		"sub":            "user-123",
		"email":          "user@example.com",
		"cognito:groups": []string{"admins", "users"},
	})

	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims := handlers.ExtractJWTClaims(r)
		if claims.Sub != "user-123" {
			t.Fatalf("claims sub = %q, want %q", claims.Sub, "user-123")
		}
		if claims.Email != "user@example.com" {
			t.Fatalf("claims email = %q, want %q", claims.Email, "user@example.com")
		}
		if len(claims.Groups) != 2 || claims.Groups[0] != "admins" || claims.Groups[1] != "users" {
			t.Fatalf("claims groups = %#v, want %#v", claims.Groups, []string{"admins", "users"})
		}

		// Headers should NOT be set (claims are in context now)
		if got := r.Header.Get("X-Amzn-Requestcontext-Authorizer-Jwt-Claim-sub"); got != "" {
			t.Fatalf("sub header = %q, want empty (claims should be in context, not headers)", got)
		}
		w.WriteHeader(http.StatusNoContent)
	})

	req := httptest.NewRequest(http.MethodGet, "/tickets", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	rec := httptest.NewRecorder()

	InjectLocalJWTClaims(next).ServeHTTP(rec, req)

	if rec.Code != http.StatusNoContent {
		t.Fatalf("status code = %d, want %d", rec.Code, http.StatusNoContent)
	}
}

func TestInjectLocalJWTClaims_MissingAuthorization_EmptyClaims(t *testing.T) {
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims := handlers.ExtractJWTClaims(r)
		if claims.Sub != "" {
			t.Fatalf("claims sub = %q, want empty", claims.Sub)
		}
		w.WriteHeader(http.StatusNoContent)
	})

	req := httptest.NewRequest(http.MethodGet, "/tickets", nil)
	rec := httptest.NewRecorder()

	InjectLocalJWTClaims(next).ServeHTTP(rec, req)

	if rec.Code != http.StatusNoContent {
		t.Fatalf("status code = %d, want %d", rec.Code, http.StatusNoContent)
	}
}

func jwtForTest(t *testing.T, claims map[string]any) string {
	t.Helper()

	header := map[string]string{"alg": "none", "typ": "JWT"}

	headerJSON, err := json.Marshal(header)
	if err != nil {
		t.Fatalf("marshal header: %v", err)
	}

	payloadJSON, err := json.Marshal(claims)
	if err != nil {
		t.Fatalf("marshal payload: %v", err)
	}

	return base64.RawURLEncoding.EncodeToString(headerJSON) + "." +
		base64.RawURLEncoding.EncodeToString(payloadJSON) + ".signature"
}
