import { Routes } from '@angular/router';

export const ImageConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./image-conversion.component').then(c => c.ImageConversionComponent)
    }
];
