import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { NodeService } from '../node';
import { HypervisorNode } from '../../../common/models/hypervisor-node';
import { ToastrService } from 'ngx-toastr';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-node-details-page',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatListModule,
    MatIconModule,
    MatProgressBarModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './node-details-page.html',
  styleUrl: './node-details-page.css',
})
export class NodeDetailsPageComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private nodeService = inject(NodeService);
  private toastr = inject(ToastrService);

  node: HypervisorNode | null = null;
  loading = true;

  ngOnInit(): void {
    this.route.paramMap.pipe(
      switchMap(params => {
        const nodeId = Number(params.get('id'));
        this.loading = true;
        return this.nodeService.getNodeById(nodeId);
      })
    ).subscribe({
      next: (response) => {
        this.node = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load node details.', 'API Error');
        this.loading = false;
      }
    });
  }

  get cpuUsage(): number {
    return this.node ? (this.node.cpuUsed / this.node.cpuCores) * 100 : 0;
  }

  get memoryUsage(): number {
    return this.node ? (this.node.memoryUsedMb / this.node.memoryTotalMb) * 100 : 0;
  }

  get diskUsage(): number {
    return this.node ? (this.node.diskUsedGb / this.node.diskTotalGb) * 100 : 0;
  }
}
