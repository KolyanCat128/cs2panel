import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { DashboardService } from '../dashboard';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-dashboard-page',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatGridListModule,
    MatIconModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './dashboard-page.html',
  styleUrl: './dashboard-page.css',
})
export class DashboardPageComponent implements OnInit {
  private dashboardService = inject(DashboardService);
  private toastr = inject(ToastrService);

  summaryCards: any[] = [];
  loading = true;

  ngOnInit(): void {
    this.loading = true;
    this.dashboardService.getSummary().subscribe({
      next: (summary) => {
        this.summaryCards = [
          { title: 'Total VMs', value: summary.totalVms, icon: 'desktop_windows', color: 'primary' },
          { title: 'Running VMs', value: summary.runningVms, icon: 'play_circle_filled', color: 'accent' },
          { title: 'Total Nodes', value: summary.totalNodes, icon: 'dns', color: 'warn' },
          { title: 'CPU Usage', value: `${summary.cpuUsage}%`, icon: 'memory', color: 'primary' },
        ];
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load dashboard summary.', 'API Error');
        this.loading = false;
      }
    });
  }
}
