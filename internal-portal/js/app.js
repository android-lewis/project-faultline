document.addEventListener('alpine:init', () => {
    // Ticket list component
    Alpine.data('ticketList', () => ({
        tickets: [],
        filterStatus: 'all',
        loading: false,
        error: null,

        init() {
            this.fetchTickets();
        },

        async fetchTickets() {
            this.loading = true;
            this.error = null;

            try {
                const response = await fetch(`${window.APP_CONFIG.API_BASE_URL}/tickets`);
                
                if (!response.ok) {
                    throw new Error(`Failed to fetch tickets: ${response.status}`);
                }

                this.tickets = await response.json();
            } catch (err) {
                this.error = err.message || 'Failed to load tickets. Please try again.';
            } finally {
                this.loading = false;
            }
        },

        get filteredTickets() {
            if (this.filterStatus === 'all') {
                return this.tickets;
            }
            return this.tickets.filter(ticket => ticket.status === this.filterStatus);
        },

        truncateId(id) {
            return id.substring(0, 8);
        },

        truncateText(text, maxLength) {
            if (!text) return '';
            if (text.length <= maxLength) return text;
            return text.substring(0, maxLength) + '...';
        },

        formatDate(dateString) {
            if (!dateString) return '';
            const date = new Date(dateString);
            return date.toLocaleDateString('en-GB', {
                day: 'numeric',
                month: 'short',
                year: 'numeric'
            });
        }
    }));

    // Ticket detail component
    Alpine.data('ticketDetail', () => ({
        ticket: null,
        newStatus: '',
        loading: false,
        updating: false,
        error: null,
        success: null,
        ticketId: null,

        init() {
            this.ticketId = this.getTicketIdFromUrl();
            if (this.ticketId) {
                this.fetchTicket();
            } else {
                this.error = 'No ticket ID provided';
            }
        },

        getTicketIdFromUrl() {
            const params = new URLSearchParams(window.location.search);
            return params.get('id');
        },

        async fetchTicket() {
            this.loading = true;
            this.error = null;

            try {
                const response = await fetch(`${window.APP_CONFIG.API_BASE_URL}/tickets/${this.ticketId}`);
                
                if (!response.ok) {
                    if (response.status === 404) {
                        throw new Error('Ticket not found');
                    }
                    throw new Error(`Failed to fetch ticket: ${response.status}`);
                }

                this.ticket = await response.json();
                this.newStatus = this.ticket.status;
            } catch (err) {
                this.error = err.message || 'Failed to load ticket. Please try again.';
            } finally {
                this.loading = false;
            }
        },

        async updateStatus() {
            this.updating = true;
            this.error = null;
            this.success = null;

            try {
                const response = await fetch(
                    `${window.APP_CONFIG.API_BASE_URL}/tickets/${this.ticketId}/status`,
                    {
                        method: 'PATCH',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({ status: this.newStatus })
                    }
                );

                if (!response.ok) {
                    const errorData = await response.json().catch(() => ({}));
                    throw new Error(errorData.error || `Failed to update status: ${response.status}`);
                }

                this.ticket = await response.json();
                this.success = 'Ticket status updated successfully';
                
                // Clear success message after 3 seconds
                setTimeout(() => {
                    this.success = null;
                }, 3000);
            } catch (err) {
                this.error = err.message || 'Failed to update ticket status. Please try again.';
            } finally {
                this.updating = false;
            }
        },

        formatDateTime(dateString) {
            if (!dateString) return '';
            const date = new Date(dateString);
            return date.toLocaleString('en-GB', {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        },

        getFilename(attachmentKey) {
            if (!attachmentKey) return '';
            const parts = attachmentKey.split('/');
            return parts[parts.length - 1];
        }
    }));
});
