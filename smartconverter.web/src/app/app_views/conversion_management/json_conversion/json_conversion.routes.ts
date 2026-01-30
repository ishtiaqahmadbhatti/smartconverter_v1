import { Routes } from '@angular/router';

export const JSONConversionRoutes: Routes = [
  {
    path: 'json-to-csv',
    loadComponent: () => import('./json-to-csv/json-to-csv.component').then(c => c.JsonToCsvComponent)
  }
];
