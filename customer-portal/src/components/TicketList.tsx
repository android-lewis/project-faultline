import { useCallback, useEffect, useState } from 'preact/hooks';
import { listTickets, type Ticket, type TicketStatus } from '../api/tickets';

interface TicketListProps {
  refreshToken: number;
}

const statusClassMap: Record<TicketStatus, string> = {
  open: 'bg-blue-100 text-blue-800',
  'in-progress': 'bg-amber-100 text-amber-800',
  closed: 'bg-emerald-100 text-emerald-800',
};

function formatStatus(status: TicketStatus): string {
  return status.replace('-', ' ');
}

function formatDate(date: string): string {
  return new Date(date).toLocaleString();
}

export function TicketList({ refreshToken }: TicketListProps) {
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [isLoading, setIsLoading] = useState(true);
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
  }, [loadTickets, refreshToken]);

  return (
    <section class="mb-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <div class="mb-4 flex items-center justify-between gap-3">
        <h2 class="text-xl font-semibold text-slate-900">Your tickets</h2>
        <button
          type="button"
          class="rounded-md border border-slate-300 px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
          onClick={() => void loadTickets()}
          disabled={isLoading}
        >
          Refresh
        </button>
      </div>

      {error && (
        <div class="mb-4 rounded-md border border-rose-200 bg-rose-50 px-3 py-2 text-sm text-rose-700">
          {error}
        </div>
      )}

      {isLoading && tickets.length === 0 ? (
        <p class="text-sm text-slate-600">Loading tickets...</p>
      ) : tickets.length === 0 ? (
        <p class="text-sm text-slate-600">No tickets yet. Submit your first ticket below.</p>
      ) : (
        <ul class="space-y-3">
          {tickets.map((ticket) => (
            <li key={ticket.id} class="rounded-lg border border-slate-200 p-4">
              <div class="mb-2 flex flex-wrap items-center gap-2">
                <span class="text-sm font-medium text-slate-900">#{ticket.id.slice(0, 8)}</span>
                <span
                  class={`rounded-full px-2 py-0.5 text-xs font-medium ${statusClassMap[ticket.status]}`}
                >
                  {formatStatus(ticket.status)}
                </span>
                <span class="text-xs text-slate-500">{formatDate(ticket.created_at)}</span>
              </div>
              <p class="text-sm text-slate-700">{ticket.description}</p>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
