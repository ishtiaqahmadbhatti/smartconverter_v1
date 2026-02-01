import { Routes } from '@angular/router';

export const CsvConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./csv-conversion.component').then(c => c.CsvConversionComponent)
    }
];
