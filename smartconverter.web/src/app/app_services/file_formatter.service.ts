import { Injectable } from '@angular/core';
import { HttpClient, HttpEvent } from '@angular/common/http';
import { ApplicationConfiguration } from '../app.config';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class FileFormatterService {

    private apiUrl: string;
    private serverBaseUrl: string;
    private formatterToolsUrl: string;

    constructor(private http: HttpClient) {
        const config = ApplicationConfiguration.Get();
        this.apiUrl = config.ApiServiceLink;
        this.serverBaseUrl = config.ServerBaseUrl;
        this.formatterToolsUrl = `${this.apiUrl}/fileformatter`;
    }

    ConvertFile(endpointSlug: string, file: File, outputFilename?: string): Observable<HttpEvent<any>> {
        const formData: FormData = new FormData();
        formData.append('file', file, file.name);
        if (outputFilename) {
            formData.append('filename', outputFilename);
        }
        // Note: The endpoint slug in data file might use dashes, but backend might expect underscores or specific paths
        // Usually we just append the slug.
        return this.http.post(`${this.formatterToolsUrl}/${endpointSlug}`, formData, {
            reportProgress: true,
            observe: 'events'
        });
    }

    downloadFile(url: string): Observable<Blob> {
        // Construct full URL if it's a relative path
        let fullUrl = url;
        if (!url.startsWith('http')) {
            // If URL starts with /, append to ServerBaseUrl (Root), not ApiUrl
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
