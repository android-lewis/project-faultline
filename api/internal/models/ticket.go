package models

import "time"

type TicketStatus string

const (
	StatusOpen       TicketStatus = "open"
	StatusClosed     TicketStatus = "closed"
	StatusInProgress TicketStatus = "in-progress"
)

type Ticket struct {
	ID          string       `json:"id" dynamodbav:"TicketID"`
	Description string       `json:"description" dynamodbav:"Description"`
	Attachments []string     `json:"attachments" dynamodbav:"Attachments"`
	Status      TicketStatus `json:"status" dynamodbav:"Status"`
	CreatedAt   time.Time    `json:"created_at" dynamodbav:"CreatedAt"`
	UpdatedAt   time.Time    `json:"updated_at" dynamodbav:"UpdatedAt"`
}

type CreateTicketRequest struct {
	Description string   `json:"description"`
	Attachments []string `json:"attachments"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
}
