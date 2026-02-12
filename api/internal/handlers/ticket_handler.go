package handlers

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/android-lewis/faultline/internal/models"
	"github.com/android-lewis/faultline/internal/repository"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
)

type TicketHandler struct {
	repo repository.TicketRepository
}

func NewTicketHandler(repo repository.TicketRepository) *TicketHandler {
	return &TicketHandler{
		repo: repo,
	}
}

func (h *TicketHandler) CreateTicket(w http.ResponseWriter, r *http.Request) {
	var req models.CreateTicketRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request payload", err.Error())
		return
	}

	if req.Description == "" {
		respondWithError(w, http.StatusBadRequest, "Description is required", "")
		return
	}

	ticket := &models.Ticket{
		ID:          uuid.New().String(),
		Description: req.Description,
		Attachments: req.Attachments,
		Status:      models.StatusOpen,
		CreatedAt:   time.Now().UTC(),
		UpdatedAt:   time.Now().UTC(),
	}

	if ticket.Attachments == nil {
		ticket.Attachments = []string{}
	}

	if err := h.repo.CreateTicket(r.Context(), ticket); err != nil {
		log.Printf("Failed to create ticket: %v", err)
		respondWithError(w, http.StatusInternalServerError, "Failed to create ticket", "")
		return
	}

	respondWithJSON(w, http.StatusCreated, ticket)
}

func (h *TicketHandler) GetTicket(w http.ResponseWriter, r *http.Request) {
	ticketID := chi.URLParam(r, "id")
	if ticketID == "" {
		respondWithError(w, http.StatusBadRequest, "Ticket ID is required", "")
		return
	}

	ticket, err := h.repo.GetTicket(r.Context(), ticketID)
	if err != nil {
		if errors.Is(err, repository.ErrTicketNotFound) {
			respondWithError(w, http.StatusNotFound, "Ticket not found", "")
			return
		}
		log.Printf("Failed to get ticket: %v", err)
		respondWithError(w, http.StatusInternalServerError, "Failed to retrieve ticket", "")
		return
	}

	respondWithJSON(w, http.StatusOK, ticket)
}

func (h *TicketHandler) ListTickets(w http.ResponseWriter, r *http.Request) {
	tickets, err := h.repo.ListTickets(r.Context())
	if err != nil {
		log.Printf("Failed to list tickets: %v", err)
		respondWithError(w, http.StatusInternalServerError, "Failed to list tickets", "")
		return
	}

	respondWithJSON(w, http.StatusOK, tickets)
}

func (h *TicketHandler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	respondWithJSON(w, http.StatusOK, map[string]string{"status": "healthy"})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, err := json.Marshal(payload)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error":"Internal server error"}`))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}

func respondWithError(w http.ResponseWriter, code int, message string, details string) {
	errResp := models.ErrorResponse{
		Error:   message,
		Message: details,
	}
	respondWithJSON(w, code, errResp)
}
