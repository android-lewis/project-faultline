package models

import (
	"fmt"
	"time"
)

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
	Reporter    string       `json:"reporter" dynamodbav:"Reporter"`
	Status      TicketStatus `json:"status" dynamodbav:"Status"`
	Summary     string       `json:"summary,omitempty" dynamodbav:"Summary,omitempty"`
	Sentiment   string       `json:"sentiment,omitempty" dynamodbav:"Sentiment,omitempty"`
	CreatedAt   time.Time    `json:"created_at" dynamodbav:"CreatedAt"`
	UpdatedAt   time.Time    `json:"updated_at" dynamodbav:"UpdatedAt"`
}

type CreateTicketRequest struct {
	Description string   `json:"description"`
	Attachments []string `json:"attachments"`
	Reporter    string   `json:"reporter"`
}

type UpdateTicketRequest struct {
	Status TicketStatus `json:"status"`
}

func (r *UpdateTicketRequest) Validate() error {
	if r.Status != StatusOpen && r.Status != StatusClosed && r.Status != StatusInProgress {
		return fmt.Errorf("invalid status: must be one of 'open', 'closed', or 'in-progress'")
	}
	return nil
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
}
