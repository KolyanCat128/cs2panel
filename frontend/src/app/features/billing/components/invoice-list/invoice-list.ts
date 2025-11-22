import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { BillingService } from '../../billing';
import { Invoice } from '../../../../common/models/invoice';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-invoice-list',
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './invoice-list.html',
  styleUrl: './invoice-list.css',
})
export class InvoiceListComponent implements OnInit {
  private billingService = inject(BillingService);
  private toastr = inject(ToastrService);

  displayedColumns: string[] = ['invoiceNumber', 'status', 'total', 'dueDate', 'paidAt'];
  dataSource = new MatTableDataSource<Invoice>();
  loading = true;

  ngOnInit(): void {
    this.loadInvoices();
  }

  loadInvoices(): void {
    this.loading = true;
    this.billingService.getInvoices().subscribe({
      next: (response) => {
        this.dataSource.data = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load invoices.', 'API Error');
        this.loading = false;
      }
    });
  }
}
