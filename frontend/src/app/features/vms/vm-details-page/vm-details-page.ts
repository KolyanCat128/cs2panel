import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { VmService } from '../vm';
import { VirtualMachine } from '../../../common/models/virtual-machine';
import { ToastrService } from 'ngx-toastr';
import { switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-vm-details-page',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatListModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './vm-details-page.html',
  styleUrl: './vm-details-page.css',
})
export class VmDetailsPageComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private vmService = inject(VmService);
  private toastr = inject(ToastrService);

  vm: VirtualMachine | null = null;
  loading = true;

  ngOnInit(): void {
    this.route.paramMap.pipe(
      switchMap(params => {
        const vmId = Number(params.get('id'));
        this.loading = true;
        return this.vmService.getVmById(vmId);
      })
    ).subscribe({
      next: (response) => {
        this.vm = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load VM details.', 'API Error');
        this.loading = false;
      }
    });
  }

  onStart(): void {
    if (this.vm) {
      this.vmService.startVm(this.vm.id).subscribe(() => {
        this.toastr.success(`Starting VM: ${this.vm!.name}`);
        // Optionally refresh VM details
      });
    }
  }

  onStop(): void {
    if (this.vm) {
      this.vmService.stopVm(this.vm.id).subscribe(() => {
        this.toastr.warning(`Stopping VM: ${this.vm!.name}`);
        // Optionally refresh VM details
      });
    }
  }

  onReboot(): void {
    if (this.vm) {
      this.vmService.rebootVm(this.vm.id).subscribe(() => {
        this.toastr.info(`Rebooting VM: ${this.vm!.name}`);
        // Optionally refresh VM details
      });
    }
  }
}
