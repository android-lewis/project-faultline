import { useCallback, useEffect, useMemo, useState } from 'preact/hooks';
import {
  getDownloadUrl,
  listTickets,
  updateTicketStatus,
  type Ticket,
  type TicketStatus,
} from '../api/tickets';

const statusLabels: Record<TicketStatus, string> = {
  open: 'Open',
  'in-progress': 'In Progress',
  closed: 'Closed',
};

const statusClassMap: Record<TicketStatus, string> = {
  open: 'bg-blue-100 text-blue-800',
  'in-progress': 'bg-amber-100 text-amber-800',
  closed: 'bg-emerald-100 text-emerald-800',
};

const statusValues: TicketStatus[] = ['open', 'in-progress', 'closed'];

function formatDate(date: string): string {
  return new Date(date).toLocaleString();
}

export function TicketList() {
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [filter, setFilter] = useState<TicketStatus | 'all'>('all');
  const [isLoading, setIsLoading] = useState(true);
  const [updatingTicketId, setUpdatingTicketId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadTickets = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const data = await listTickets();
      const sorted = [...data].sort(
        (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );
      setTickets(sorted);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load tickets');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadTickets();
  }, [loadTickets]);

  const filteredTickets = useMemo(() => {
    if (filter === 'all') {
      return tickets;
    }
    return tickets.filter((ticket) => ticket.status === filter);
  }, [tickets, filter]);

  const handleStatusChange = async (ticketId: string, status: TicketStatus) => {
    setUpdatingTicketId(ticketId);
    setError(null);

    try {
      const updatedTicket = await updateTicketStatus(ticketId, status);
      setTickets((currentTickets) =>
        currentTickets.map((ticket) => (ticket.id === ticketId ? updatedTicket : ticket))
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update ticket status');
    } finally {
      setUpdatingTicketId(null);
    }
  };

  const handleAttachmentOpen = async (key: string) => {
    setError(null);
    try {
      const { downloadUrl } = await getDownloadUrl(key);
      window.open(downloadUrl, '_blank', 'noopener,noreferrer');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to open attachment');
    }
  };

  return (
    <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <div class="mb-4 flex flex-wrap items-center justify-between gap-3">
        <h2 class="text-xl font-semibold text-slate-900">All tickets</h2>
        <button
          type="button"
          class="rounded-md border border-slate-300 px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
          onClick={() => void loadTickets()}
          disabled={isLoading}
        >
          Refresh
        </button>
      </div>

      <div class="mb-4 flex flex-wrap items-center gap-2">
        <button
          type="button"
          class={`rounded-full px-3 py-1 text-xs font-semibold ${
            filter === 'all' ? 'bg-slate-900 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
          }`}
          onClick={() => setFilter('all')}
        >
          All
        </button>
        {statusValues.map((status) => (
          <button
            key={status}
            type="button"
            class={`rounded-full px-3 py-1 text-xs font-semibold ${
              filter === status
                ? 'bg-slate-900 text-white'
                : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
            }`}
            onClick={() => setFilter(status)}
          >
            {statusLabels[status]}
          </button>
        ))}
      </div>

      {error && (
        <div class="mb-4 rounded-md border border-rose-200 bg-rose-50 px-3 py-2 text-sm text-rose-700">
          {error}
        </div>
      )}

      {isLoading && tickets.length === 0 ? (
        <p class="text-sm text-slate-600">Loading tickets...</p>
      ) : filteredTickets.length === 0 ? (
        <p class="text-sm text-slate-600">No tickets match this filter.</p>
      ) : (
        <ul class="space-y-3">
          {filteredTickets.map((ticket) => (
            <li key={ticket.id} class="rounded-lg border border-slate-200 p-4">
              <div class="mb-2 flex flex-wrap items-center gap-2">
                <span class="text-sm font-medium text-slate-900">#{ticket.id.slice(0, 8)}</span>
                <span class={`rounded-full px-2 py-0.5 text-xs font-medium ${statusClassMap[ticket.status]}`}>
                  {statusLabels[ticket.status]}
                </span>
                <span class="text-xs text-slate-500">{formatDate(ticket.created_at)}</span>
                {ticket.user_email && (
                  <span class="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-700">
                    {ticket.user_email}
                  </span>
                )}
              </div>

              <p class="mb-3 text-sm text-slate-700">{ticket.description}</p>

              <div class="flex flex-wrap items-center gap-3">
                <label class="text-xs font-semibold tracking-wide text-slate-600 uppercase">
                  Status
                </label>
                <select
                  class="rounded-md border border-slate-300 px-2 py-1 text-sm text-slate-800"
                  value={ticket.status}
                  disabled={updatingTicketId === ticket.id}
                  onChange={(event) =>
                    void handleStatusChange(
                      ticket.id,
                      (event.currentTarget as HTMLSelectElement).value as TicketStatus
                    )
                  }
                >
                  {statusValues.map((status) => (
                    <option key={status} value={status}>
                      {statusLabels[status]}
                    </option>
                  ))}
                </select>
                {updatingTicketId === ticket.id && (
                  <span class="text-xs text-slate-500">Updating...</span>
                )}
              </div>

              {ticket.attachments.length > 0 && (
                <div class="mt-3 flex flex-wrap items-center gap-2">
                  <span class="text-xs font-semibold tracking-wide text-slate-600 uppercase">
                    Attachments
                  </span>
                  {ticket.attachments.map((key, index) => (
                    <button
                      key={key}
                      type="button"
                      class="rounded-md border border-slate-300 px-2 py-1 text-xs text-slate-700 hover:bg-slate-50"
                      onClick={() => void handleAttachmentOpen(key)}
                    >
                      File {index + 1}
                    </button>
                  ))}
                </div>
              )}
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
