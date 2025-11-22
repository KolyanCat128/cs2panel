import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatDialogRef, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { NodeService } from '../../node';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-node-add-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './node-add-dialog.html',
  styleUrl: './node-add-dialog.css',
})
export class NodeAddDialogComponent {
  private fb = inject(FormBuilder);
  private nodeService = inject(NodeService);
  private dialogRef = inject(MatDialogRef<NodeAddDialogComponent>);
  private toastr = inject(ToastrService);

  loading = false;

  nodeForm = this.fb.group({
    name: ['', [Validators.required]],
    ipAddress: ['', [Validators.required]],
    port: [8080, [Validators.required, Validators.min(1), Validators.max(65535)]],
  });

  onSubmit(): void {
    if (this.nodeForm.valid) {
      this.loading = true;
      this.nodeService.addNode(this.nodeForm.value as any).subscribe({
        next: () => {
          this.toastr.success('Node added successfully!');
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.loading = false;
          this.toastr.error('Failed to add node.', 'API Error');
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
