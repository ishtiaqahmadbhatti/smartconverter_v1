import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { ApplicationConfiguration } from '../app.config';
import { ConvertModel, PDFOperationResponse } from '../app_controllers/models.controller';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root'})
export class ConvertService {

  private apiUrl =ApplicationConfiguration.Get().ApiServiceLink + 'Convert';
  constructor(private http: HttpClient) { }


  convertPdfToWord(file: File): Observable<Blob> {
    const formData: FormData = new FormData();
    formData.append('pdfFile', file, file.name);
  
    return this.http.post(`${this.apiUrl}/pdf-to-word`, formData, {
      responseType: 'blob'
    });
  }
  
  convertWordToPdf(file: File): Observable<Blob> {
    const formData: FormData = new FormData();
    formData.append('wordFile', file, file.name);
  
    return this.http.post(`${this.apiUrl}/word-to-pdf`, formData, {
      responseType: 'blob'
    });
  }

  mergePdfs(files: File[]): Observable<PDFOperationResponse> {
    const formData: FormData = new FormData();
    files.forEach((file, index) => formData.append('files', file, file.name));
 
    return this.http.post<PDFOperationResponse>(`${ApplicationConfiguration.Get().ApiServiceLink}pdf/merge`, formData);
  }
 
  convertImageToPdf(file: File): Observable<Blob> {
    const formData: FormData = new FormData();
    formData.append('imageFile', file, file.name);
 
    return this.http.post(`${this.apiUrl}/image-to-pdf`, formData, {
      responseType: 'blob'
    });
  }
  
  convertVideoToAudio(file: File): Observable<Blob> {
    const formData = new FormData();
    formData.append('VideoFile', file, file.name);

    return this.http.post(`${this.apiUrl}/video-to-audio`, formData, {
      responseType: 'blob'
    });
  }

  downloadFile(downloadUrl: string): Observable<Blob> {
    // Convert /download/filename.pdf to convert/download/filename.pdf (remove leading slash to avoid double slash)
    const correctedUrl = downloadUrl.replace('/download/', 'convert/download/');
    return this.http.get(`${ApplicationConfiguration.Get().ApiServiceLink}${correctedUrl}`, {
      responseType: 'blob'
    });
  }
}
