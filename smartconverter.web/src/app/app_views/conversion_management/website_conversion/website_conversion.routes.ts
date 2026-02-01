import { Routes } from '@angular/router';

export const WebsiteConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./website-conversion.component').then(c => c.WebsiteConversionComponent)
    }
];
