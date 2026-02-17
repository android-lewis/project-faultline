import { apiRequest } from './client';

export type TicketStatus = 'open' | 'in-progress' | 'closed';

export interface Ticket {
  id: string;
  description: string;
  attachments: string[];
  reporter?: string;
  user_id?: string;
  user_email?: string;
  status: TicketStatus;
  created_at: string;
  updated_at: string;
}

export interface UploadUrlResponse {
  uploadUrl: string;
  key: string;
}

interface CreateTicketRequest {
  description: string;
  attachments: string[];
}

export async function listTickets(): Promise<Ticket[]> {
  return apiRequest<Ticket[]>('/tickets');
}

export async function createTicket(
  description: string,
  attachments: string[]
): Promise<Ticket> {
  const payload: CreateTicketRequest = { description, attachments };
  return apiRequest<Ticket>('/tickets', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}

export async function getUploadUrl(
  filename: string,
  contentType?: string
): Promise<UploadUrlResponse> {
  const query = new URLSearchParams({ filename });
  if (contentType) {
    query.set('contentType', contentType);
  }

  return apiRequest<UploadUrlResponse>(`/tickets/upload-url?${query.toString()}`, {
    method: 'GET',
  });
}

export async function uploadFileToS3(uploadUrl: string, file: File): Promise<void> {
  const response = await fetch(uploadUrl, {
    method: 'PUT',
    body: file,
  });

  if (!response.ok) {
    throw new Error(`Upload failed: ${response.status}`);
  }
}
