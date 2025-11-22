import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { UserService } from '../../user';
import { User } from '../../../../common/models/user';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-user-edit-dialog',
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
  templateUrl: './user-edit-dialog.html',
  styleUrl: './user-edit-dialog.css',
})
export class UserEditDialogComponent implements OnInit {
  private fb = inject(FormBuilder);
  private userService = inject(UserService);
  private dialogRef = inject(MatDialogRef<UserEditDialogComponent>);
  private toastr = inject(ToastrService);
  public data: User = inject(MAT_DIALOG_DATA);

  loading = false;

  userForm = this.fb.group({
    username: ['', [Validators.required]],
    email: ['', [Validators.required, Validators.email]],
    firstName: [''],
    lastName: [''],
  });

  ngOnInit(): void {
    this.userForm.patchValue(this.data);
  }

  onSubmit(): void {
    if (this.userForm.valid) {
      this.loading = true;
      this.userService.updateUser(this.data.id, this.userForm.value as any).subscribe({
        next: () => {
          this.toastr.success('User updated successfully!');
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.loading = false;
          this.toastr.error('Failed to update user.', 'API Error');
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
