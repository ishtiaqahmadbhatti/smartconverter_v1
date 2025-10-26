import { Component } from '@angular/core';
import { ConvertService } from '../../../app_controllers/services.controller';
import { PDFOperationResponse } from '../../../app_controllers/models.controller';
import { CommonModule } from '@angular/common';
@Component({
  selector: 'app-merge-pdfs',
  templateUrl: './merge-pdfs.component.html',
  styleUrls: ['./merge-pdfs.component.css'],
  standalone: true,
  imports: [CommonModule]
})
export class MergePdfsComponent {
  selectedFiles: File[] = [];
  isProcessing: boolean = false;
  errorMessage: string = '';
  successMessage: string = '';

  constructor(private convertService: ConvertService) { }
  onFilesSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.selectedFiles = Array.from(input.files);
      this.clearMessages();
    }
  }

  mergePdfs(): void {
    if (this.selectedFiles.length < 2) {
      this.errorMessage = 'Please select at least 2 PDF files to merge.';
      return;
    }

    this.isProcessing = true;
    this.clearMessages();

    this.convertService.mergePdfs(this.selectedFiles).subscribe({
      next: (response: PDFOperationResponse) => {
        this.isProcessing = false;
        if (response.success) {
          this.successMessage = response.message;
          this.downloadMergedFile(response.download_url, response.output_filename);
        } else {
          this.errorMessage = response.message || 'Failed to merge PDFs.';
        }
      },
      error: (error) => {
        this.isProcessing = false;
        console.error('Error merging PDFs:', error);
        this.errorMessage = error.error?.message || 'An error occurred while merging PDFs.';
      }
    });
  }

  private downloadMergedFile(downloadUrl: string, filename: string): void {
    this.convertService.downloadFile(downloadUrl).subscribe({
      next: (data: Blob) => {
        this.downloadFile(data, filename);
      },
      error: (error) => {
        console.error('Error downloading file:', error);
        this.errorMessage = 'Failed to download the merged PDF.';
      }
    });
  }

  private downloadFile(data: Blob, filename: string): void {
    const url = window.URL.createObjectURL(data);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }

  clearMessages(): void {
    this.errorMessage = '';
    this.successMessage = '';
  }

  removeFile(index: number): void {
    this.selectedFiles.splice(index, 1);
    this.clearMessages();
  }
}
