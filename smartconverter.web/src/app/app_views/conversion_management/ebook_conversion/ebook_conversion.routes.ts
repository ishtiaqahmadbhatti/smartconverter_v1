import { Routes } from '@angular/router';

export const EbookConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./ebook-conversion.component').then(c => c.EbookConversionComponent)
    }
];
