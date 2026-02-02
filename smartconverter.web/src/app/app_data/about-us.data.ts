export const ABOUT_US_DATA = {
    appVersion: '1.0.0', // Should probably align with package.json, but hardcoding for now as per mobile
    intro: 'Smart Converter is your ultimate all-in-one file processing companion. Easily convert, edit, and manage documents, images, audio, and video files with our powerful suite of tools designed for speed and efficiency.',
    stats: [
        {
            value: '14+',
            label: 'Categories',
            icon: 'fa-solid fa-layer-group',
            color: '#448aff' // Primary Blue
        },
        {
            value: '90+',
            label: 'Tools',
            icon: 'fa-solid fa-toolbox',
            color: '#00c853' // Secondary Green
        }
    ],
    features: [
        {
            title: 'PDF Tools',
            icon: 'fa-solid fa-file-pdf',
            tools: [
                'Merge, Split, Compress PDF',
                'Remove/Extract Pages',
                'Rotate, Crop, Add Watermark',
                'Protect, Unlock, Repair PDF',
                'Compare PDFs, Get Metadata',
                'Convert to Word, Excel, CSV',
                'Convert to JPG, PNG, SVG',
                'Convert to HTML, Text, JSON'
            ]
        },
        {
            title: 'Image Tools',
            icon: 'fa-solid fa-image',
            tools: [
                'Convert between JPG, PNG, WebP',
                'Support for AVIF, TIFF, BMP, HEIC',
                'Convert SVG to Raster',
                'Website/HTML to Image',
                'Remove EXIF Data'
            ]
        },
        {
            title: 'Video Tools',
            icon: 'fa-solid fa-film',
            tools: [
                'Convert MOV, MKV, AVI to MP4',
                'Video to MP3 (Extract Audio)',
                'Resize & Compress Video',
                'Get Video Information'
            ]
        },
        {
            title: 'Audio Tools',
            icon: 'fa-solid fa-music',
            tools: [
                'Convert WAV, FLAC to MP3',
                'Convert MP3 to WAV',
                'Trim & Normalize Audio',
                'Get Audio Information'
            ]
        },
        {
            title: 'Office Documents',
            icon: 'fa-solid fa-file-word',
            tools: [
                'Word, PowerPoint to PDF/HTML',
                'Excel to PDF, CSV, XML, HTML',
                'OpenOffice (ODS) Support',
                'Extract Text from Docs'
            ]
        },
        {
            title: 'E-Book Tools',
            icon: 'fa-solid fa-book',
            tools: [
                'Convert ePUB, MOBI, AZW to PDF',
                'Convert PDF to eBook Formats',
                'Support for FB2, FBZ, AZW3'
            ]
        },
        {
            title: 'OCR (Text Recognition)',
            icon: 'fa-solid fa-print', // fa-document-scanner replacement
            tools: [
                'Image (PNG/JPG) to Text/PDF',
                'PDF to Text',
                'Extract Text from Scans'
            ]
        },
        {
            title: 'Data Conversion (CSV/JSON/XML)',
            icon: 'fa-solid fa-database',
            tools: [
                'Convert JSON to CSV, Excel, XML',
                'Convert CSV to JSON, Excel, XML',
                'Convert XML to JSON, CSV, Excel',
                'JSON/XML Formatter & Validator',
                'Minify JSON',
                'AI: PDF/Image to JSON/CSV'
            ]
        },
        {
            title: 'Subtitle Tools',
            icon: 'fa-solid fa-closed-captioning',
            tools: [
                'AI Translate Subtitles',
                'Convert SRT <-> VTT',
                'Convert Subtitles to CSV/Excel',
                'Convert Subtitles to Text'
            ]
        },
        {
            title: 'Website Tools',
            icon: 'fa-solid fa-globe',
            tools: [
                'Website/HTML to PDF',
                'Website/HTML to Image',
                'Convert HTML Tables to CSV'
            ]
        }
    ],
    socialLinks: [
        {
            label: 'Website',
            url: 'https://www.techmindsforge.com',
            icon: 'fa-solid fa-globe',
            color: '#00C853' // Greenish
        },
        {
            label: 'Facebook',
            url: 'https://www.facebook.com/techmindsforge',
            icon: 'fa-brands fa-facebook-f',
            color: '#1877F2'
        },
        {
            label: 'LinkedIn',
            url: 'https://www.linkedin.com/in/techmindsforge/',
            icon: 'fa-brands fa-linkedin-in',
            color: '#0A66C2'
        },
        {
            label: 'YouTube',
            url: 'https://youtube.com/@techmindsforge',
            icon: 'fa-brands fa-youtube',
            color: '#FF0000'
        }
    ]
};
