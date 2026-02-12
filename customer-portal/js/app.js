document.addEventListener('alpine:init', () => {
    Alpine.data('ticketForm', () => ({
        description: '',
        files: [],
        submitting: false,
        success: null,
        error: null,

        handleFileSelect(event) {
            const selectedFiles = Array.from(event.target.files);
            this.files = selectedFiles;
        },

        removeFile(index) {
            this.files.splice(index, 1);
            document.getElementById('attachments').value = '';
        },

        formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
        },

        async submitTicket() {
            this.success = null;
            this.error = null;
            this.submitting = true;

            try {
                const attachmentKeys = [];

                // Upload files to S3 via presigned URLs
                if (this.files.length > 0) {
                    for (const file of this.files) {
                        try {
                            const key = await this.uploadFile(file);
                            attachmentKeys.push(key);
                        } catch (err) {
                            throw new Error(`Failed to upload ${file.name}: ${err.message}`);
                        }
                    }
                }

                // Create the ticket
                const response = await fetch(`${window.APP_CONFIG.API_BASE_URL}/tickets`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        description: this.description.trim(),
                        attachments: attachmentKeys
                    })
                });

                if (!response.ok) {
                    const errorData = await response.json().catch(() => ({}));
                    throw new Error(errorData.message || `Server error: ${response.status}`);
                }

                const data = await response.json();
                this.success = data.id || data.ID || 'Created successfully';
                
                // Reset form
                this.description = '';
                this.files = [];
                document.getElementById('attachments').value = '';
            } catch (err) {
                this.error = err.message || 'An unexpected error occurred. Please try again.';
            } finally {
                this.submitting = false;
            }
        },

        async uploadFile(file) {
            // Get presigned upload URL
            const urlResponse = await fetch(
                `${window.APP_CONFIG.API_BASE_URL}/tickets/upload-url?filename=${encodeURIComponent(file.name)}&contentType=${encodeURIComponent(file.type)}`,
                { method: 'GET' }
            );

            if (!urlResponse.ok) {
                throw new Error(`Failed to get upload URL: ${urlResponse.status}`);
            }

            const { uploadUrl, key } = await urlResponse.json();

            // Upload file to S3
            const uploadResponse = await fetch(uploadUrl, {
                method: 'PUT',
                body: file,
                headers: {
                    'Content-Type': file.type
                }
            });

            if (!uploadResponse.ok) {
                throw new Error(`Upload failed: ${uploadResponse.status}`);
            }

            return key;
        }
    }));
});
