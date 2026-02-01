import { Routes } from '@angular/router';

export const XmlConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./xml-conversion.component').then(c => c.XmlConversionComponent)
    }
];
