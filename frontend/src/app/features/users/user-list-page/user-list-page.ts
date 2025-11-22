import { Component, OnInit, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { UserService } from '../user';
import { User } from '../../../common/models/user';
import { ToastrService } from 'ngx-toastr';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog';
import { UserCreateDialogComponent } from '../components/user-create-dialog/user-create-dialog';
import { UserEditDialogComponent } from '../components/user-edit-dialog/user-edit-dialog';

@Component({
  selector: 'app-user-list-page',
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
  templateUrl: './user-list-page.html',
  styleUrl: './user-list-page.css',
})
export class UserListPageComponent implements OnInit {
  private userService = inject(UserService);
  private toastr = inject(ToastrService);
  private dialog = inject(MatDialog);

  displayedColumns: string[] = ['username', 'email', 'firstName', 'lastName', 'enabled', 'actions'];
  dataSource = new MatTableDataSource<User>();
  loading = true;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.loading = true;
    this.userService.getAllUsers().subscribe({
      next: (response) => {
        this.dataSource.data = response.data;
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
        this.loading = false;
      },
      error: (err) => {
        this.toastr.error('Failed to load users.', 'API Error');
        this.loading = false;
      }
    });
  }

  openCreateUserDialog(): void {
    const dialogRef = this.dialog.open(UserCreateDialogComponent);
    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadUsers();
      }
    });
  }

  openEditUserDialog(user: User): void {
    const dialogRef = this.dialog.open(UserEditDialogComponent, { data: user });
    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadUsers();
      }
    });
  }

  onDelete(user: User): void {
    const dialogData: ConfirmDialogData = {
      title: 'Confirm Deletion',
      message: `Are you sure you want to delete the user "${user.username}"?`
    };

    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: dialogData
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.userService.deleteUser(user.id).subscribe(() => {
          this.toastr.error(`Deleted user: ${user.username}`);
          this.loadUsers();
        });
      }
    });
  }
}
