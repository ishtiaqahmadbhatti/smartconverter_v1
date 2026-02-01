import { CommonModule } from '@angular/common';
import { HttpClient, HttpEvent, HttpEventType } from '@angular/common/http';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { PDFConversionService } from '../../../../app_services/pdf_conversion.service';
import { ToastService } from '../../../../app_services/toast';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';

@Component({
  selector: 'app-remove-pages',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './remove-pages.component.html',
  styleUrl: './remove-pages.component.css',
  standalone: true
})
export class RemovePagesComponent {
  selectedFile: File | null = null;
  outputFilename: string = '';
  isConverting: boolean = false;

  uploadProgress: number = 0;
  conversionStatus: string = '';

  conversionResult: { downloadUrl: string, fileName: string } | null = null;

  constructor(
    private pdfService: PDFConversionService,
    private toastService: ToastService
  ) { }

  onFileSelected(file: File): void {
    if (file) {
      this.selectedFile = file;
      const nameWithoutExt = file.name.substring(0, file.name.lastIndexOf('.'));
      this.outputFilename = nameWithoutExt;
      this.conversionResult = null;
      this.uploadProgress = 0;
      this.conversionStatus = '';
      this.toastService.show('File selected successfully', 'success');
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

    this.pdfService.ConvertFile('remove-pages', this.selectedFile, this.outputFilename)
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
              setTimeout(() => {
                const response = event.body;
                if (response && response.download_url) {
                  this.conversionResult = {
                    downloadUrl: response.download_url,
                    fileName: response.output_filename || 'converted_result'
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
    this.pdfService.downloadFile(this.conversionResult.downloadUrl).subscribe({
      next: (blob) => {
        this.downloadBlob(blob, this.conversionResult!.fileName);
        this.toastService.show('File saved successfully!', 'success');
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
    this.outputFilename = '';
    this.isConverting = false;
    this.conversionResult = null;
  }
}
