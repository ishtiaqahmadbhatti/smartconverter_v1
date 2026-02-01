import { Routes } from '@angular/router';

export const TextConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./text-conversion.component').then(c => c.TextConversionComponent)
    }
];
