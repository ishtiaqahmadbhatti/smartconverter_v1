import { Routes } from '@angular/router';

export const VideoConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./video-conversion.component').then(c => c.VideoConversionComponent)
    }
];
