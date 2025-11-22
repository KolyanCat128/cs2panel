import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiResponse } from '../../common/dto/api-response';
import { BillingPlan } from '../../common/models/billing-plan';
import { Subscription } from '../../common/models/subscription';
import { Invoice } from '../../common/models/invoice';

@Injectable({
  providedIn: 'root',
})
export class BillingService {
  private http = inject(HttpClient);
  private readonly API_URL = '/api/v1/billing';

  getPlans(): Observable<ApiResponse<BillingPlan[]>> {
    return this.http.get<ApiResponse<BillingPlan[]>>(`${this.API_URL}/plans`);
  }

  getSubscriptions(): Observable<ApiResponse<Subscription[]>> {
    return this.http.get<ApiResponse<Subscription[]>>(`${this.API_URL}/subscriptions`);
  }

  getInvoices(): Observable<ApiResponse<Invoice[]>> {
    return this.http.get<ApiResponse<Invoice[]>>(`${this.API_URL}/invoices`);
  }
}
