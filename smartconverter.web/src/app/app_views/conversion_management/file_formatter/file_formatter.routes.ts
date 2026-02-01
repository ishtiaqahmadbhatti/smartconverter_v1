import { Routes } from '@angular/router';

export const FileFormatterRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./file-formatter-formatter.component').then(c => c.FileFormatterComponent)
    }
];
