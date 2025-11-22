import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatDialogRef, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSelectModule } from '@angular/material/select';
import { VmService } from '../../vm';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-vm-create-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatSelectModule
  ],
  templateUrl: './vm-create-dialog.html',
  styleUrl: './vm-create-dialog.css',
})
export class VmCreateDialogComponent {
  private fb = inject(FormBuilder);
  private vmService = inject(VmService);
  private dialogRef = inject(MatDialogRef<VmCreateDialogComponent>);
  private toastr = inject(ToastrService);

  loading = false;

  vmForm = this.fb.group({
    name: ['', [Validators.required]],
    cpuCores: [1, [Validators.required, Validators.min(1)]],
    memoryMb: [1024, [Validators.required, Validators.min(512)]],
    diskGb: [20, [Validators.required, Validators.min(10)]],
    osType: ['linux', [Validators.required]],
    cloudInitData: [''],
  });

  osTypes = ['linux', 'windows'];

  onSubmit(): void {
    if (this.vmForm.valid) {
      this.loading = true;
      this.vmService.createVm(this.vmForm.value as any).subscribe({
        next: () => {
          this.toastr.success('VM created successfully!');
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.loading = false;
          this.toastr.error('Failed to create VM.', 'API Error');
        },
        complete: () => {
          this.loading = false;
        }
      });
    }
  }

  onCancel(): void {
    this.dialogRef.close();
  }
}
