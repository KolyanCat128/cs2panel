import { Injectable, inject } from '@angular/core';
import { forkJoin, Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { VmService } from '../vms/vm';
import { NodeService } from '../nodes/node';

export interface DashboardSummary {
  totalVms: number;
  runningVms: number;
  totalNodes: number;
  cpuUsage: number; // This will be a dummy value for now
}

@Injectable({
  providedIn: 'root',
})
export class DashboardService {
  private vmService = inject(VmService);
  private nodeService = inject(NodeService);

  getSummary(): Observable<DashboardSummary> {
    return forkJoin({
      vms: this.vmService.getAllVms(),
      nodes: this.nodeService.getAllNodes(),
    }).pipe(
      map(({ vms, nodes }) => {
        const runningVms = vms.data.filter(vm => vm.status === 'RUNNING').length;
        return {
          totalVms: vms.data.length,
          runningVms: runningVms,
          totalNodes: nodes.data.length,
          cpuUsage: 75, // Dummy data for now
        };
      })
    );
  }
}
