import { Routes } from '@angular/router';

export const VideoConversionRoutes: Routes = [
    {
        path: '',
        loadComponent: () => import('./video-conversion.component').then(c => c.VideoConversionComponent)
    },
    {
        path: 'mov-to-mp4',
        loadComponent: () => import('./mov-to-mp4/mov-to-mp4.component').then(c => c.MovToMp4Component)
    },
    {
        path: 'mkv-to-mp4',
        loadComponent: () => import('./mkv-to-mp4/mkv-to-mp4.component').then(c => c.MkvToMp4Component)
    },
    {
        path: 'avi-to-mp4',
        loadComponent: () => import('./avi-to-mp4/avi-to-mp4.component').then(c => c.AviToMp4Component)
    },
    {
        path: 'mp4-to-mp3',
        loadComponent: () => import('./mp4-to-mp3/mp4-to-mp3.component').then(c => c.Mp4ToMp3Component)
    },
    {
        path: 'convert-video-format',
        loadComponent: () => import('./convert-video-format/convert-video-format.component').then(c => c.ConvertVideoFormatComponent)
    },
    {
        path: 'video-to-audio',
        loadComponent: () => import('./video-to-audio/video-to-audio.component').then(c => c.VideoToAudioComponent)
    },
    {
        path: 'extract-audio',
        loadComponent: () => import('./extract-audio/extract-audio.component').then(c => c.ExtractAudioComponent)
    },
    {
        path: 'resize-video',
        loadComponent: () => import('./resize-video/resize-video.component').then(c => c.ResizeVideoComponent)
    },
    {
        path: 'compress-video',
        loadComponent: () => import('./compress-video/compress-video.component').then(c => c.CompressVideoComponent)
    },
    {
        path: 'video-info',
        loadComponent: () => import('./video-info/video-info.component').then(c => c.VideoInfoComponent)
    }
];
