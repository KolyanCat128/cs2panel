import { Routes } from '@angular/router';
import { DashboardPageComponent } from './features/dashboard/dashboard-page/dashboard-page';
import { VmListPageComponent } from './features/vms/vm-list-page/vm-list-page';
import { NodeListPageComponent } from './features/nodes/node-list-page/node-list-page';
import { MainLayoutComponent } from './core/layout/main-layout/main-layout';
import { authGuard } from './core/auth/auth-guard';

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    import { VmDetailsPageComponent } from './features/vms/vm-details-page/vm-details-page';

// ... (existing imports)

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    import { NodeDetailsPageComponent } from './features/nodes/node-details-page/node-details-page';

// ... (existing imports)

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    import { UserListPageComponent } from './features/users/user-list-page/user-list-page';

// ... (existing imports)

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    import { BillingPageComponent } from './features/billing/billing-page/billing-page';

// ... (existing imports)

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    children: [
      { path: 'dashboard', component: DashboardPageComponent },
      { path: 'vms', component: VmListPageComponent },
      { path: 'vms/:id', component: VmDetailsPageComponent },
      { path: 'nodes', component: NodeListPageComponent },
      { path: 'nodes/:id', component: NodeDetailsPageComponent },
      { path: 'users', component: UserListPageComponent },
      { path: 'billing', component: BillingPageComponent },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  // ... (existing routes)
];

  },
  // ... (existing routes)
];

  },
  // ... (existing routes)
];
  },
  // ... (existing routes)
];

  },
  {
    path: 'login',
    loadComponent: () => import('./features/auth/login-page/login-page').then(m => m.LoginPageComponent)
  },
  {
    path: 'register',
    loadComponent: () => import('./features/auth/register-page/register-page').then(m => m.RegisterPageComponent)
  },
  { path: '**', redirectTo: 'dashboard' } // Wildcard route for a 404 page
];
