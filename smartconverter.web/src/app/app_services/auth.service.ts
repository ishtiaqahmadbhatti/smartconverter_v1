import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { Router } from '@angular/router';
import { ApplicationConfiguration } from '../app.config';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl: string;
  private readonly TOKEN_KEY = 'access_token';
  private readonly REFRESH_TOKEN_KEY = 'refresh_token';
  private readonly USER_NAME_KEY = 'user_name';
  private readonly USER_EMAIL_KEY = 'user_email';

  private authUrl: string;

  private isLoggedInSubject = new BehaviorSubject<boolean>(this.hasToken());
  public isLoggedIn$ = this.isLoggedInSubject.asObservable();

  constructor(private http: HttpClient, private router: Router) {
    this.apiUrl = ApplicationConfiguration.Get().ApiServiceLink;
    this.authUrl = `${this.apiUrl}/auth/`;
  }

  private hasToken(): boolean {
    if (typeof localStorage !== 'undefined') {
      return !!localStorage.getItem(this.TOKEN_KEY);
    }
    return false;
  }

  register(userData: any): Observable<any> {
    const url = `${this.authUrl}register-userlist`;
    return this.http.post(url, userData);
  }

  login(credentials: { email: string, password: string }): Observable<any> {
    const url = `${this.authUrl}login-userlist`;
    return this.http.post(url, credentials);
  }

  saveTokens(access: string, refresh: string, name?: string, email?: string): void {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem(this.TOKEN_KEY, access);
      localStorage.setItem(this.REFRESH_TOKEN_KEY, refresh);
      if (name) localStorage.setItem(this.USER_NAME_KEY, name);
      if (email) localStorage.setItem(this.USER_EMAIL_KEY, email);
      this.isLoggedInSubject.next(true);
    }
  }

  getToken(): string | null {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem(this.TOKEN_KEY);
    }
    return null;
  }

  getUserName(): string | null {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem(this.USER_NAME_KEY);
    }
    return null;
  }

  getUserEmail(): string | null {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem(this.USER_EMAIL_KEY);
    }
    return null;
  }

  getUserInitials(): string {
    const name = this.getUserName();
    if (!name) return 'U';

    const parts = name.trim().split(' ');
    if (parts.length === 1) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  logout(): void {
    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem(this.TOKEN_KEY);
      localStorage.removeItem(this.REFRESH_TOKEN_KEY);
      localStorage.removeItem(this.USER_NAME_KEY);
      localStorage.removeItem(this.USER_EMAIL_KEY);
      this.isLoggedInSubject.next(false);
    }
    this.router.navigate(['/']);
  }

  isLoggedIn(): boolean {
    return this.isLoggedInSubject.value; // Use the subject's current value for synchronous check
  }
}
