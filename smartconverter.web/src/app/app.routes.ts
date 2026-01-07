import { Routes } from '@angular/router';

export const AppRoutes: Routes = [
  {
    path: '',
    redirectTo: '',
    pathMatch: 'full',
  },
  {
    path: '',
    loadComponent: () => import('./app_views/home/home/home.component').then(c => c.HomeComponent)
  },
  {
    path: 'authentication',
    loadChildren: () => import('./app_views/authentication/authentication.routes').then(r =>r.AuthenticatioRoutes),
  },
  {
    path: 'profile',
    loadChildren: () => import('./app_views/profile/profile.routes').then(r => r.ProfileRoutes),
  },
  {
    path: 'verification',
    loadChildren: () => import('./app_views/verification/verification.routes').then(r => r.VerificationRoutes),
  },
  {
    path: 'convert',
    loadChildren: () => import('./app_views/convert/convert.routes').then(r => r.ConvertRoutes),
  }
];
