import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { BillingService } from '../../billing';
import { BillingPlan } from '../../../../common/models/billing-plan';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-plan-list',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatButtonModule,
    MatGridListModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './plan-list.html',
  styleUrl: './plan-list.css',
})
export class PlanListComponent implements OnInit {
  private billingService = inject(BillingService);
  private toastr = inject(ToastrService);

  plans: BillingPlan[] = [];
  loading = true;

  ngOnInit(): void {
    this.loadPlans();
  }

  loadPlans(): void {
    this.loading = true;
    this.billingService.getPlans().subscribe({
      next: (response) => {
        this.plans = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load billing plans.', 'API Error');
        this.loading = false;
      }
    });
  }

  onSubscribe(plan: BillingPlan): void {
    this.toastr.info(`Subscribing to ${plan.name} is not yet implemented.`);
  }
}
