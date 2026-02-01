import { Injectable } from '@angular/core';
import { HttpClient, HttpEvent } from '@angular/common/http';
import { ApplicationConfiguration } from '../app.config';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class PDFConversionService {

  private apiUrl: string;
  private serverBaseUrl: string;
  private pdfToolsUrl: string;

  constructor(private http: HttpClient) {
    const config = ApplicationConfiguration.Get();
    this.apiUrl = config.ApiServiceLink;
    this.serverBaseUrl = config.ServerBaseUrl;
    this.pdfToolsUrl = `${this.apiUrl}/pdfconversiontools`;
  }



  ConvertFile(endpointSlug: string, file: File, outputFilename?: string): Observable<HttpEvent<any>> {
    const formData: FormData = new FormData();
    formData.append('file', file, file.name);
    if (outputFilename) {
      formData.append('filename', outputFilename);
    }
    return this.http.post(`${this.pdfToolsUrl}/${endpointSlug}`, formData, {
      reportProgress: true,
      observe: 'events'
    });
  }

  downloadFile(url: string): Observable<Blob> {
    // Construct full URL if it's a relative path
    let fullUrl = url;
    if (!url.startsWith('http')) {
      if (url.startsWith('/')) {
        fullUrl = `${this.serverBaseUrl}${url}`;
      } else {
        fullUrl = `${this.serverBaseUrl}/${url}`;
      }
    }

    return this.http.get(fullUrl, {
      responseType: 'blob'
    });
  }
}
