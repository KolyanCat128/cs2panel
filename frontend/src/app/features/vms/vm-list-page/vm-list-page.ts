import { Component, OnInit, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { VmService } from '../vm';
import { VirtualMachine } from '../../../common/models/virtual-machine';
import { ToastrService } from 'ngx-toastr';
import { VmCreateDialogComponent } from '../components/vm-create-dialog/vm-create-dialog';
import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog';

@Component({
  selector: 'app-vm-list-page',
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatDialogModule
  ],
  templateUrl: './vm-list-page.html',
  styleUrl: './vm-list-page.css',
})
export class VmListPageComponent implements OnInit {
  private vmService = inject(VmService);
  private toastr = inject(ToastrService);
  private dialog = inject(MatDialog);

  displayedColumns: string[] = ['name', 'status', 'ipAddress', 'cpuCores', 'memoryMb', 'diskGb', 'actions'];
  dataSource = new MatTableDataSource<VirtualMachine>();
  loading = true;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  ngOnInit(): void {
    this.loadVms();
  }

  loadVms(): void {
    this.loading = true;
    this.vmService.getAllVms().subscribe({
      next: (response) => {
        this.dataSource.data = response.data;
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load VMs.', 'API Error');
        this.loading = false;
      }
    });
  }

  openCreateVmDialog(): void {
    const dialogRef = this.dialog.open(VmCreateDialogComponent);

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadVms();
      }
    });
  }

  onDelete(vm: VirtualMachine): void {
    const dialogData: ConfirmDialogData = {
      title: 'Confirm Deletion',
      message: `Are you sure you want to delete the VM "${vm.name}"? This action cannot be undone.`
    };

    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: dialogData
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.vmService.deleteVm(vm.id).subscribe(() => {
          this.toastr.error(`Deleted VM: ${vm.name}`);
          this.loadVms();
        });
      }
    });
  }
}
