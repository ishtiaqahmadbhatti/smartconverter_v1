import { CommonModule } from '@angular/common';
import { HttpClient, HttpEvent, HttpEventType } from '@angular/common/http';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { JSONConversionService } from '../../../../app_services/json_conversion.service';
import { ToastService } from '../../../../app_services/toast';

@Component({
  selector: 'app-json-to-csv',
  imports: [CommonModule, FormsModule],
  templateUrl: './json-to-csv.component.html',
  styleUrl: './json-to-csv.component.css',
})
export class JsonToCsvComponent {
  selectedFile: File | null = null;
  delimiter: string = ',';
  outputFilename: string = '';
  isConverting: boolean = false;

  uploadProgress: number = 0;
  conversionStatus: string = '';

  conversionResult: { downloadUrl: string, fileName: string } | null = null;

  constructor(
    private jsonService: JSONConversionService,
    private toastService: ToastService
  ) { }

  onFileSelected(event: any): void {
    const file = event.target.files[0];
    if (file && file.type === 'application/json') {
      this.selectedFile = file;
      // Auto-suggest filename without extension
      const nameWithoutExt = file.name.substring(0, file.name.lastIndexOf('.'));
      this.outputFilename = nameWithoutExt;
      this.conversionResult = null; // Reset result on new file selection
      this.uploadProgress = 0;
      this.conversionStatus = '';
      this.toastService.show('JSON file selected successfully', 'success');
    } else {
      this.toastService.show('Please select a valid JSON file', 'error');
      this.selectedFile = null;
    }
  }

  convert(): void {
    if (!this.selectedFile) {
      this.toastService.show('Please select a file first', 'error');
      return;
    }

    this.isConverting = true;
    this.conversionResult = null;
    this.uploadProgress = 0;
    this.conversionStatus = 'Initializing...';

    this.jsonService.convertJsonToCsv(this.selectedFile, this.delimiter, this.outputFilename)
      .subscribe({
        next: (event: HttpEvent<any>) => {
          switch (event.type) {
            case HttpEventType.Sent:
              this.conversionStatus = 'Request sent...';
              break;
            case HttpEventType.UploadProgress:
              if (event.total) {
                this.uploadProgress = Math.round(100 * event.loaded / event.total);
                this.conversionStatus = `File Uploading... ${this.uploadProgress}%`;
              }
              break;
            case HttpEventType.Response:
              this.conversionStatus = 'File Converting...';
              // Simulate a small delay for user experience if response is too fast
              setTimeout(() => {
                const response = event.body;
                if (response && response.download_url) {
                  this.conversionResult = {
                    downloadUrl: response.download_url,
                    fileName: response.output_filename || this.outputFilename + '.csv' || 'converted.csv'
                  };
                  this.isConverting = false;
                  this.toastService.show('File converted successfully. Ready to save.', 'success');
                } else {
                  this.toastService.show('Conversion failed: No download URL returned.', 'error');
                  this.isConverting = false;
                  this.conversionStatus = 'Failed';
                }
              }, 500);
              break;
          }
        },
        error: (error) => {
          this.handleError(error);
        }
      });
  }

  saveFile(): void {
    if (!this.conversionResult) return;

    this.jsonService.downloadFile(this.conversionResult.downloadUrl).subscribe({
      next: (blob) => {
        this.downloadBlob(blob, this.conversionResult!.fileName);
        this.toastService.show('File saved successfully!', 'success');
        // Reset the page after successful save as requested
        this.reset();
      },
      error: (err) => {
        console.error('Download failed', err);
        this.toastService.show('Download failed. Please try again.', 'error');
      }
    });
  }

  private handleError(error: any): void {
    console.error('Conversion failed', error);
    this.toastService.show('Conversion failed. Please try again.', 'error');
    this.isConverting = false;
  }

  private downloadBlob(blob: Blob, filename: string): void {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }

  reset(): void {
    this.selectedFile = null;
    this.delimiter = ',';
    this.outputFilename = '';
    this.isConverting = false;
    this.conversionResult = null;
  }
}
