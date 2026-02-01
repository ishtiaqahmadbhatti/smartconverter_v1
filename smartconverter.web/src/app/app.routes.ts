import { Routes } from '@angular/router';

export const AppRoutes: Routes = [
  {
    path: '',
    redirectTo: '',
    pathMatch: 'full',
  },
  {
    path: '',
    loadComponent: () => import('./app_views/home/home/home.component').then(c => c.HomeComponent)
  },
  {
    path: 'authentication',
    loadChildren: () => import('./app_views/user_management/user_authentication/user_authentication.routes').then(r => r.AuthenticatioRoutes),
  },
  {
    path: 'profile',
    loadChildren: () => import('./app_views/user_management/user_profile/user_profile.routes').then(r => r.ProfileRoutes),
  },
  {
    path: 'verification',
    loadChildren: () => import('./app_views/user_management/user_verification/user_verification.routes').then(r => r.VerificationRoutes),
  },
  {
    path: 'pdfconversion',
    loadChildren: () => import('./app_views/conversion_management/pdf_conversion/pdf_conversion.routes').then(r => r.PDFConversionRoutes),
  },
  {
    path: 'jsonconversion',
    loadChildren: () => import('./app_views/conversion_management/json_conversion/json_conversion.routes').then(r => r.JSONConversionRoutes),
  },
  {
    path: 'audioconversion',
    loadChildren: () => import('./app_views/conversion_management/audio_conversion/audio_conversion.routes').then(r => r.AudioConversionRoutes),
  },
  {
    path: 'csvconversion',
    loadChildren: () => import('./app_views/conversion_management/csv_conversion/csv_conversion.routes').then(r => r.CSVConversionRoutes),
  },
  {
    path: 'ebookconversion',
    loadChildren: () => import('./app_views/conversion_management/ebook_conversion/ebook_conversion.routes').then(r => r.EbookConversionRoutes),
  },
  {
    path: 'fileformatter',
    loadChildren: () => import('./app_views/conversion_management/file_formatter/file_formatter.routes').then(r => r.FileFormatterRoutes),
  },
  {
    path: 'imageconversion',
    loadChildren: () => import('./app_views/conversion_management/image_conversion/image_conversion.routes').then(r => r.ImageConversionRoutes),
  },
  {
    path: 'ocrconversion',
    loadChildren: () => import('./app_views/conversion_management/ocr_conversion/ocr_conversion.routes').then(r => r.OcrConversionRoutes),
  },
  {
    path: 'officeconversion',
    loadChildren: () => import('./app_views/conversion_management/office_conversion/office_conversion.routes').then(r => r.OfficeConversionRoutes),
  },
  {
    path: 'subtitleconversion',
    loadChildren: () => import('./app_views/conversion_management/subtitle_conversion/subtitle_conversion.routes').then(r => r.SubtitleConversionRoutes),
  },
  {
    path: 'textconversion',
    loadChildren: () => import('./app_views/conversion_management/text_conversion/text_conversion.routes').then(r => r.TextConversionRoutes),
  },
  {
    path: 'videoconversion',
    loadChildren: () => import('./app_views/conversion_management/video_conversion/video_conversion.routes').then(r => r.VideoConversionRoutes),
  },
  {
    path: 'websiteconversion',
    loadChildren: () => import('./app_views/conversion_management/website_conversion/website_conversion.routes').then(r => r.WebsiteConversionRoutes),
  },
  {
    path: 'xmlconversion',
    loadChildren: () => import('./app_views/conversion_management/xml_conversion/xml_conversion.routes').then(r => r.XMLConversionRoutes),
  }
];
