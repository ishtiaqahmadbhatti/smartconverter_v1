import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withFetch, withInterceptors } from '@angular/common/http';
import { provideClientHydration } from '@angular/platform-browser';
import { AppRoutes } from './app.routes';
import { authInterceptor } from './app_services/auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(AppRoutes),
    provideClientHydration(),
    provideHttpClient(withFetch(), withInterceptors([authInterceptor])),
  ],
};

export class ApplicationConfiguration {
  public ServerBaseUrl: string = 'http://192.168.8.100:8000';
  public ApiServiceLink: string = 'http://192.168.8.100:8000/api/v1';
  public WebSiteLink: string = 'https://techmindsforge.com/';

  static Get() {
    var acon = new ApplicationConfiguration();
    return acon;
  }
}
