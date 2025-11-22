import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTabsModule } from '@angular/material/tabs';
import { PlanListComponent } from '../components/plan-list/plan-list';
import { SubscriptionListComponent } from '../components/subscription-list/subscription-list';
import { InvoiceListComponent } from '../components/invoice-list/invoice-list';

@Component({
  selector: 'app-billing-page',
  standalone: true,
  imports: [
    CommonModule,
    MatTabsModule,
    PlanListComponent,
    SubscriptionListComponent,
    InvoiceListComponent
  ],
  templateUrl: './billing-page.html',
  styleUrl: './billing-page.css',
})
export class BillingPageComponent {

}
