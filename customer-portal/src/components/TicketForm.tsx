import { useRef, useState } from 'preact/hooks';
import { createTicket, getUploadUrl, uploadFileToS3 } from '../api/tickets';

interface TicketFormProps {
  onSubmitted: () => void;
}

function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  const units = ['Bytes', 'KB', 'MB', 'GB'];
  const power = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
  const value = bytes / Math.pow(1024, power);
  return `${Math.round(value * 100) / 100} ${units[power]}`;
}

export function TicketForm({ onSubmitted }: TicketFormProps) {
  const [description, setDescription] = useState('');
  const [files, setFiles] = useState<File[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successId, setSuccessId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const onFileChange = (event: Event) => {
    const target = event.currentTarget as HTMLInputElement;
    setFiles(Array.from(target.files ?? []));
  };

  const removeFile = (index: number) => {
    setFiles((currentFiles) => currentFiles.filter((_, i) => i !== index));
  };

  const submitTicket = async (event: Event) => {
    event.preventDefault();

    const trimmedDescription = description.trim();
    if (!trimmedDescription) {
      return;
    }

    setIsSubmitting(true);
    setError(null);
    setSuccessId(null);

    try {
      const attachmentKeys: string[] = [];

      for (const file of files) {
        const { uploadUrl, key } = await getUploadUrl(file.name, file.type);
        await uploadFileToS3(uploadUrl, file);
        attachmentKeys.push(key);
      }

      const ticket = await createTicket(trimmedDescription, attachmentKeys);
      setSuccessId(ticket.id);
      setDescription('');
      setFiles([]);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
      onSubmitted();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to submit ticket');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <h2 class="mb-1 text-xl font-semibold text-slate-900">Submit a support ticket</h2>
      <p class="mb-5 text-sm text-slate-600">
        Describe your issue and attach any relevant files.
      </p>

      <form class="space-y-5" onSubmit={(event) => void submitTicket(event)}>
        <div class="space-y-2">
          <label for="description" class="block text-sm font-medium text-slate-700">
            Description <span class="text-rose-600">*</span>
          </label>
          <textarea
            id="description"
            rows={8}
            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-900 shadow-sm outline-none ring-slate-300 placeholder:text-slate-400 focus:ring-2"
            placeholder="Please describe your issue in detail..."
            value={description}
            onInput={(event) => setDescription((event.currentTarget as HTMLTextAreaElement).value)}
            disabled={isSubmitting}
            required
          />
        </div>

        <div class="space-y-2">
          <label for="attachments" class="block text-sm font-medium text-slate-700">
            Attachments (optional)
          </label>
          <input
            id="attachments"
            ref={fileInputRef}
            type="file"
            multiple
            disabled={isSubmitting}
            onChange={onFileChange}
            class="block w-full cursor-pointer rounded-lg border border-slate-300 bg-white p-2 text-sm text-slate-600 file:mr-4 file:rounded-md file:border-0 file:bg-slate-100 file:px-3 file:py-2 file:text-sm file:font-medium file:text-slate-700 hover:file:bg-slate-200"
          />

          {files.length > 0 && (
            <ul class="space-y-2 rounded-lg bg-slate-50 p-3">
              {files.map((file, index) => (
                <li key={`${file.name}-${index}`} class="flex items-center gap-2 text-sm">
                  <span class="truncate text-slate-800">{file.name}</span>
                  <span class="text-xs text-slate-500">{formatFileSize(file.size)}</span>
                  <button
                    type="button"
                    class="ml-auto rounded-md px-2 py-1 text-xs font-medium text-rose-700 hover:bg-rose-50"
                    onClick={() => removeFile(index)}
                    disabled={isSubmitting}
                  >
                    Remove
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <button
          type="submit"
          disabled={isSubmitting || !description.trim()}
          class="inline-flex items-center justify-center rounded-lg bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {isSubmitting ? 'Submitting...' : 'Submit ticket'}
        </button>

        {successId && (
          <div class="rounded-md border border-emerald-200 bg-emerald-50 px-3 py-2 text-sm text-emerald-800">
            Ticket submitted successfully. Ticket ID: <span class="font-semibold">{successId}</span>
          </div>
        )}

        {error && (
          <div class="rounded-md border border-rose-200 bg-rose-50 px-3 py-2 text-sm text-rose-700">
            {error}
          </div>
        )}
      </form>
    </section>
  );
}
