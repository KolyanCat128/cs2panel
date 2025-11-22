import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';
import { BillingService } from '../../billing';
import { Subscription } from '../../../../common/models/subscription';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-subscription-list',
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatProgressSpinnerModule,
    MatIconModule
  ],
  templateUrl: './subscription-list.html',
  styleUrl: './subscription-list.css',
})
export class SubscriptionListComponent implements OnInit {
  private billingService = inject(BillingService);
  private toastr = inject(ToastrService);

  displayedColumns: string[] = ['plan', 'status', 'startDate', 'endDate', 'autoRenew'];
  dataSource = new MatTableDataSource<Subscription>();
  loading = true;

  ngOnInit(): void {
    this.loadSubscriptions();
  }

  loadSubscriptions(): void {
    this.loading = true;
    this.billingService.getSubscriptions().subscribe({
      next: (response) => {
        this.dataSource.data = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load subscriptions.', 'API Error');
        this.loading = false;
      }
    });
  }
}
