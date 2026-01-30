import { Routes } from '@angular/router';

export const ProfileRoutes: Routes = [
  {
    path: 'updateprofile',
    loadComponent: () => import('./user-profile-update/user-profile-update.component').then(c => c.UserProfileUpdateComponent)
  },
  {
    path: 'deleteprofile',
    loadComponent: () => import('./user-profile-delete/user-profile-delete.component').then(c => c.UserProfileDeleteComponent)
  },
];