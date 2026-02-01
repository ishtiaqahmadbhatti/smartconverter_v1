import { Routes } from '@angular/router';

export const SubtitleConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./subtitle-conversion.component').then(c => c.SubtitleConversionComponent)
    }
];
