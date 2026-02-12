package main

import (
	"context"
	"log"
	"os"

	"github.com/android-lewis/faultline/internal/handlers"
	"github.com/android-lewis/faultline/internal/repository"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	chiadapter "github.com/awslabs/aws-lambda-go-api-proxy/chi"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

var chiLambda *chiadapter.ChiLambdaV2

func init() {
	tableName := os.Getenv("DYNAMODB_TABLE_NAME")
	if tableName == "" {
		log.Fatal("DYNAMODB_TABLE_NAME environment variable is required")
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

	ticketRepo := repository.NewDynamoDBTicketRepository(dynamoClient, tableName)
	ticketHandler := handlers.NewTicketHandler(ticketRepo)
	setupRouter(ticketHandler)
}

func setupRouter(ticketHandler *handlers.TicketHandler) {
	r := chi.NewRouter()

	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RequestID)
	r.Use(middleware.SetHeader("Content-Type", "application/json"))

	r.Get("/health", ticketHandler.HealthCheck)
	r.Post("/tickets", ticketHandler.CreateTicket)
	r.Get("/tickets/{id}", ticketHandler.GetTicket)
	r.Get("/tickets", ticketHandler.ListTickets)

	chiLambda = chiadapter.NewV2(r)
}

func main() {
	lambda.Start(chiLambda.ProxyWithContextV2)
}
