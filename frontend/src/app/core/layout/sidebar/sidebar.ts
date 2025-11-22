import { Component } from '@angular/core';
import { RouterModule } from '@angular/router';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [
    RouterModule,
    MatListModule,
    MatIconModule
  ],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class SidebarComponent {
  menuItems = [
    { path: '/dashboard', icon: 'dashboard', label: 'Dashboard' },
    { path: '/vms', icon: 'desktop_windows', label: 'Virtual Machines' },
    { path: '/nodes', icon: 'dns', label: 'Nodes' },
    { path: '/billing', icon: 'payment', label: 'Billing' },
    { path: '/users', icon: 'group', label: 'Users' },
  ];
}
