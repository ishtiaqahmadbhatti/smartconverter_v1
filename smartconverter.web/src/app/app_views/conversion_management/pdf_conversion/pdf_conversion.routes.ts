import { Routes } from '@angular/router';

export const PDFConversionRoutes: Routes = [
  {
    path: 'pdf-to-word',
    loadComponent: () => import('./pdf-to-word/pdf-to-word.component').then(c => c.PdfToWordComponent)
  }
];
