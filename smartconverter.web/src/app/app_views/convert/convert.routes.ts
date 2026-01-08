import { Routes } from '@angular/router';

export const ConvertRoutes: Routes = [
  {
    path: 'pdf-to-word',
    loadComponent: () => import('./pdf-to-word/pdf-to-word.component').then(c => c.PdfToWordComponent)
  },
  {
    path: 'video-to-audio',
    loadComponent: () => import('./video-to-audio/video-to-audio.component').then(c => c.VideoToAudioComponent)
  }
];
