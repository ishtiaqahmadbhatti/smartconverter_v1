import { Injectable } from '@angular/core';
import { HttpClient, HttpEvent } from '@angular/common/http';
import { ApplicationConfiguration } from '../app.config';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class JSONConversionService {

  private apiUrl = ApplicationConfiguration.Get().ApiServiceLink;

  constructor(private http: HttpClient) { }

  convertJsonToCsv(file: File, delimiter?: string, outputFilename?: string): Observable<HttpEvent<any>> {
    const formData: FormData = new FormData();
    formData.append('file', file, file.name);
    if (delimiter) {
      formData.append('delimiter', delimiter);
    }
    if (outputFilename) {
      formData.append('filename', outputFilename);
    }
    return this.http.post(`${this.apiUrl}/jsonconversiontools/json-to-csv`, formData, {
      reportProgress: true,
      observe: 'events'
    });
  }

  downloadFile(url: string): Observable<Blob> {
    // Construct full URL if it's a relative path
    let fullUrl = url;
    if (!url.startsWith('http')) {
      // Get base URL from ApiServiceLink (remove /api/v1 suffix if present in download url or just use the host)
      // Assuming ApiServiceLink is http://host:port/api/v1
      // and download_url is usually /api/v1/... or just /...

      const apiLink = ApplicationConfiguration.Get().ApiServiceLink;
      const baseUrl = apiLink.substring(0, apiLink.indexOf('/api/v1'));

      if (url.startsWith('/')) {
        fullUrl = `${baseUrl}${url}`;
      } else {
        fullUrl = `${baseUrl}/${url}`;
      }
    }

    return this.http.get(fullUrl, {
      responseType: 'blob'
    });
  }

}
