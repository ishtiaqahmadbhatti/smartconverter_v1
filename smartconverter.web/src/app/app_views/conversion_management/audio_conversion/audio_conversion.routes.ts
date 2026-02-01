import { Routes } from '@angular/router';

export const AudioConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./audio-conversion.component').then(c => c.AudioConversionComponent)
    }
];
