package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/android-lewis/project-faultline/internal/models"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

var ErrTicketNotFound = errors.New("ticket not found")

type TicketRepository interface {
	CreateTicket(ctx context.Context, ticket *models.Ticket) error
	GetTicket(ctx context.Context, id string) (*models.Ticket, error)
	ListTickets(ctx context.Context) ([]models.Ticket, error)
}

type DynamoDBTicketRepository struct {
	client    *dynamodb.Client
	tableName string
}

func NewDynamoDBTicketRepository(client *dynamodb.Client, tableName string) *DynamoDBTicketRepository {
	return &DynamoDBTicketRepository{
		client:    client,
		tableName: tableName,
	}
}

func (r *DynamoDBTicketRepository) CreateTicket(ctx context.Context, ticket *models.Ticket) error {
	item, err := attributevalue.MarshalMap(ticket)
	if err != nil {
		return fmt.Errorf("failed to marshal ticket: %w", err)
	}

	_, err = r.client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: aws.String(r.tableName),
		Item:      item,
	})

	if err != nil {
		return fmt.Errorf("failed to put item: %w", err)
	}

	return nil
}

func (r *DynamoDBTicketRepository) GetTicket(ctx context.Context, id string) (*models.Ticket, error) {
	result, err := r.client.GetItem(ctx, &dynamodb.GetItemInput{
		TableName: aws.String(r.tableName),
		Key: map[string]types.AttributeValue{
			"TicketID": &types.AttributeValueMemberS{Value: id},
		},
	})

	if err != nil {
		return nil, fmt.Errorf("failed to get item: %w", err)
	}

	if result.Item == nil {
		return nil, ErrTicketNotFound
	}

	var ticket models.Ticket
	err = attributevalue.UnmarshalMap(result.Item, &ticket)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal ticket: %w", err)
	}

	return &ticket, nil
}

func (r *DynamoDBTicketRepository) ListTickets(ctx context.Context) ([]models.Ticket, error) {
	result, err := r.client.Scan(ctx, &dynamodb.ScanInput{
		TableName: aws.String(r.tableName),
	})

	if err != nil {
		return nil, fmt.Errorf("failed to scan table: %w", err)
	}

	var tickets []models.Ticket
	err = attributevalue.UnmarshalListOfMaps(result.Items, &tickets)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal tickets: %w", err)
	}

	return tickets, nil
}
