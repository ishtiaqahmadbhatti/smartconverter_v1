import { Routes } from '@angular/router';

export const OfficeConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./office-conversion.component').then(c => c.OfficeConversionComponent)
    }
];
