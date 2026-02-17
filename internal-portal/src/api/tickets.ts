import {
  apiRequest,
  getDownloadUrl as getDownloadUrlFromCommon,
  listTickets as listTicketsFromCommon,
  type DownloadUrlResponse,
  type Ticket,
  type TicketStatus,
} from '@project-faultline/common';

export type { DownloadUrlResponse, Ticket, TicketStatus };

export async function listTickets(): Promise<Ticket[]> {
  return listTicketsFromCommon();
}

export async function updateTicketStatus(ticketId: string, status: TicketStatus): Promise<Ticket> {
  return apiRequest<Ticket>(`/tickets/${ticketId}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ status }),
  });
}

export async function getDownloadUrl(key: string): Promise<DownloadUrlResponse> {
  return getDownloadUrlFromCommon(key);
}
