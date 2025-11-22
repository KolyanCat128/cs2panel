import { Component, OnInit, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { NodeService } from '../node';
import { HypervisorNode } from '../../../common/models/hypervisor-node';
import { ToastrService } from 'ngx-toastr';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { NodeAddDialogComponent } from '../components/node-add-dialog/node-add-dialog';

@Component({
  selector: 'app-node-list-page',
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
  templateUrl: './node-list-page.html',
  styleUrl: './node-list-page.css',
})
export class NodeListPageComponent implements OnInit {
  private nodeService = inject(NodeService);
  private toastr = inject(ToastrService);
  private dialog = inject(MatDialog);

  displayedColumns: string[] = ['name', 'status', 'ipAddress', 'cpuCores', 'memoryTotalMb', 'diskTotalGb', 'actions'];
  dataSource = new MatTableDataSource<HypervisorNode>();
  loading = true;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  ngOnInit(): void {
    this.loadNodes();
  }

  loadNodes(): void {
    this.loading = true;
    this.nodeService.getAllNodes().subscribe({
      next: (response) => {
        this.dataSource.data = response.data;
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load nodes.', 'API Error');
        this.loading = false;
      }
    });
  }

  openAddNodeDialog(): void {
    const dialogRef = this.dialog.open(NodeAddDialogComponent);

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadNodes();
      }
    });
  }

  import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog';

// ... (existing imports)

@Component({
  // ... (existing component decorator)
})
export class NodeListPageComponent implements OnInit {
  // ... (existing properties)

  onDelete(node: HypervisorNode): void {
    const dialogData: ConfirmDialogData = {
      title: 'Confirm Deletion',
      message: `Are you sure you want to delete the node "${node.name}"? This action cannot be undone.`
    };

    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: dialogData
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.nodeService.deleteNode(node.id).subscribe(() => {
          this.toastr.error(`Deleted node: ${node.name}`);
          this.loadNodes();
        });
      }
    });
  }

  // ... (existing methods)
}

}
