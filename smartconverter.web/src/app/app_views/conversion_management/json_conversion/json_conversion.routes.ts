import { Routes } from '@angular/router';

export const JSONConversionRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./json-conversion.component').then(c => c.JsonConversionComponent)
  },
  {
    path: 'json-to-csv',
    loadComponent: () => import('./json-to-csv/json-to-csv.component').then(c => c.JsonToCsvComponent)
  }
];
