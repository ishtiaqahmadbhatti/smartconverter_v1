import { Routes } from '@angular/router';

export const OcrConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./ocr-conversion.component').then(c => c.OcrConversionComponent)
    }
];
