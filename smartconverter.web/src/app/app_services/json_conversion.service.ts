import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ApplicationConfiguration } from '../app.config';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class JSONConversionService {

  private apiUrl = ApplicationConfiguration.Get().ApiServiceLink + 'pdfconversiontools';

  constructor(private http: HttpClient) { }

  convertPdfToWord(file: File): Observable<Blob> {
    debugger
    const formData: FormData = new FormData();
    formData.append('pdfFile', file, file.name);
    return this.http.post(`${this.apiUrl}/pdf-to-word`, formData, {
      responseType: 'blob'
    });
  }

}
