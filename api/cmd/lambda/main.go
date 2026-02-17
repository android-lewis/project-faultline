package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/android-lewis/project-faultline/internal/handlers"
	localmiddleware "github.com/android-lewis/project-faultline/internal/middleware"
	"github.com/android-lewis/project-faultline/internal/repository"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	chiadapter "github.com/awslabs/aws-lambda-go-api-proxy/chi"
	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
)

var (
	chiLambda *chiadapter.ChiLambdaV2
	router    *chi.Mux
)

func init() {
	tableName := os.Getenv("DYNAMODB_TABLE_NAME")
	if tableName == "" {
		log.Fatal("DYNAMODB_TABLE_NAME environment variable is required")
	}

	bucketName := os.Getenv("S3_BUCKET_NAME")
	if bucketName == "" {
		log.Fatal("S3_BUCKET_NAME environment variable is required")
	}

	ctx := context.Background()

	// Support DynamoDB Local endpoint for local development
	var dynamoClient *dynamodb.Client
	if endpointURL := os.Getenv("DYNAMODB_ENDPOINT_URL"); endpointURL != "" {
		log.Printf("Using custom DynamoDB endpoint: %s", endpointURL)
		cfg, err := config.LoadDefaultConfig(ctx,
			config.WithRegion("eu-west-2"),
			config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider("dummy", "dummy", "")),
		)

		if err != nil {
			log.Fatalf("Failed to load AWS config: %v", err)
		}

		dynamoClient = dynamodb.NewFromConfig(cfg, func(o *dynamodb.Options) {
			o.BaseEndpoint = &endpointURL
		})

	} else {
		cfg, err := config.LoadDefaultConfig(ctx)

		if err != nil {
			log.Fatalf("Failed to load AWS config: %v", err)
		}

		dynamoClient = dynamodb.NewFromConfig(cfg)
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatalf("Failed to load AWS config: %v", err)
	}

	s3Client := s3.NewFromConfig(cfg)
	ticketRepo := repository.NewDynamoDBTicketRepository(dynamoClient, tableName)
	ticketHandler := handlers.NewTicketHandler(ticketRepo, s3Client, bucketName)
	setupRouter(ticketHandler)
}

func setupRouter(ticketHandler *handlers.TicketHandler) {
	r := chi.NewRouter()

	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.RequestID)
	if shouldInjectLocalJWTClaims() {
		r.Use(localmiddleware.InjectLocalJWTClaims)
	}
	r.Use(corsMiddleware)
	r.Use(chimiddleware.SetHeader("Content-Type", "application/json"))

	r.Get("/health", ticketHandler.HealthCheck)
	r.Post("/tickets", ticketHandler.CreateTicket)
	r.Get("/tickets/{id}", ticketHandler.GetTicket)
	r.Get("/tickets", ticketHandler.ListTickets)
	r.Patch("/tickets/{id}/status", ticketHandler.UpdateTicketStatus)
	r.Get("/tickets/upload-url", ticketHandler.GetUploadURL)
	r.Get("/tickets/download-url", ticketHandler.GetDownloadURL)

	router = r
	chiLambda = chiadapter.NewV2(r)
}

func shouldInjectLocalJWTClaims() bool {
	return os.Getenv("LOCAL_SERVER_PORT") != "" || strings.EqualFold(os.Getenv("AWS_SAM_LOCAL"), "true")
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PATCH, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	if port := os.Getenv("LOCAL_SERVER_PORT"); port != "" {
		log.Printf("Starting local HTTP server on :%s", port)
		log.Fatal(http.ListenAndServe(":"+port, router))
	}
	lambda.Start(chiLambda.ProxyWithContextV2)
}
