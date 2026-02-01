import { Routes } from '@angular/router';

export const PDFConversionRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pdf-conversion.component').then(c => c.PdfConversionComponent)
  },
  {
    path: 'pdf-to-word',
    loadComponent: () => import('./pdf-to-word/pdf-to-word.component').then(c => c.PdfToWordComponent)
  }
];
