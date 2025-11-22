import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { jwtDecode } from 'jwt-decode';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly TOKEN_KEY = 'access_token';
  private readonly API_URL = '/api/v1/auth'; // Adjust if your backend URL is different

  private _isLoggedIn = new BehaviorSubject<boolean>(this.hasToken());
  public isLoggedIn$ = this._isLoggedIn.asObservable();

  constructor(private http: HttpClient) {}

  login(credentials: {username: string, password: string}): Observable<any> {
    return this.http.post(`${this.API_URL}/login`, credentials).pipe(
      tap((response: any) => {
        this.setToken(response.token);
        this._isLoggedIn.next(true);
      })
    );
  }

  logout(): void {
    this.removeToken();
    this._isLoggedIn.next(false);
    // Here you might want to navigate the user to the login page
  }

  register(userInfo: any): Observable<any> {
    return this.http.post(`${this.API_URL}/register`, userInfo);
  }

  public getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  public setToken(token: string): void {
    localStorage.setItem(this.TOKEN_KEY, token);
  }

  public removeToken(): void {
    localStorage.removeItem(this.TOKEN_KEY);
  }

  public hasToken(): boolean {
    return !!this.getToken();
  }

  public getUserRoles(): string[] {
    const token = this.getToken();
    if (token) {
      const decoded: any = jwtDecode(token);
      return decoded.roles || [];
    }
    return [];
  }
}
