import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { VmCreateDialogComponent } from '../components/vm-create-dialog/vm-create-dialog';

// ... (existing imports)

@Component({
  // ... (existing component decorator)
  imports: [
    // ... (existing imports)
    MatDialogModule
  ],
})
export class VmListPageComponent implements OnInit {
  private vmService = inject(VmService);
  private toastr = inject(ToastrService);
  private dialog = inject(MatDialog);

  // ... (existing properties)

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
