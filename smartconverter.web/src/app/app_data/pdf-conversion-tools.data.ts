import { ConversionTool } from '../app_models/conversion-tool.model';

export const PDF_CONVERSION_TOOLS: ConversionTool[] = [
    {
        id: 'pdf-to-json',
        title: 'PDF to JSON',
        description: 'Convert PDF documents to JSON format.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-code',
        route: 'pdf-to-json'
    },
    {
        id: 'pdf-to-markdown',
        title: 'PDF to Markdown',
        description: 'Convert PDF documents to Markdown format.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fab fa-markdown',
        route: 'pdf-to-markdown'
    },
    {
        id: 'pdf-to-csv-ai',
        title: 'PDF to CSV (AI)',
        description: ' intelligently convert PDF tables to CSV using AI.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-csv',
        route: 'pdf-to-csv-ai'
    },
    {
        id: 'pdf-to-excel-ai',
        title: 'PDF to Excel (AI)',
        description: 'Intelligently convert PDF tables to Excel using AI.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-excel',
        route: 'pdf-to-excel-ai'
    },
    {
        id: 'html-to-pdf',
        title: 'HTML to PDF',
        description: 'Convert HTML content to PDF format.',
        sourceIcon: 'fas fa-code',
        targetIcon: 'fas fa-file-pdf',
        route: 'html-to-pdf'
    },
    {
        id: 'word-to-pdf',
        title: 'Word to PDF',
        description: 'Convert Word documents to PDF format.',
        sourceIcon: 'fas fa-file-word',
        targetIcon: 'fas fa-file-pdf',
        route: 'word-to-pdf'
    },
    {
        id: 'powerpoint-to-pdf',
        title: 'PowerPoint to PDF',
        description: 'Convert PowerPoint presentations to PDF.',
        sourceIcon: 'fas fa-file-powerpoint',
        targetIcon: 'fas fa-file-pdf',
        route: 'powerpoint-to-pdf'
    },
    {
        id: 'oxps-to-pdf',
        title: 'OXPS to PDF',
        description: 'Convert OXPS files to PDF format.',
        sourceIcon: 'fas fa-file',
        targetIcon: 'fas fa-file-pdf',
        route: 'oxps-to-pdf'
    },
    {
        id: 'jpg-to-pdf',
        title: 'JPG to PDF',
        description: 'Convert JPG images to PDF documents.',
        sourceIcon: 'fas fa-file-image',
        targetIcon: 'fas fa-file-pdf',
        route: 'jpg-to-pdf'
    },
    {
        id: 'png-to-pdf',
        title: 'PNG to PDF',
        description: 'Convert PNG images to PDF documents.',
        sourceIcon: 'fas fa-file-image',
        targetIcon: 'fas fa-file-pdf',
        route: 'png-to-pdf'
    },
    {
        id: 'markdown-to-pdf',
        title: 'Markdown to PDF',
        description: 'Convert Markdown content to PDF.',
        sourceIcon: 'fab fa-markdown',
        targetIcon: 'fas fa-file-pdf',
        route: 'markdown-to-pdf'
    },
    {
        id: 'excel-to-pdf',
        title: 'Excel to PDF',
        description: 'Convert Excel spreadsheets to PDF.',
        sourceIcon: 'fas fa-file-excel',
        targetIcon: 'fas fa-file-pdf',
        route: 'excel-to-pdf'
    },
    {
        id: 'excel-to-xps',
        title: 'Excel to XPS',
        description: 'Convert Excel spreadsheets to XPS format.',
        sourceIcon: 'fas fa-file-excel',
        targetIcon: 'fas fa-print',
        route: 'excel-to-xps'
    },
    {
        id: 'ods-to-pdf',
        title: 'ODS to PDF',
        description: 'Convert ODS files to PDF format.',
        sourceIcon: 'fas fa-table',
        targetIcon: 'fas fa-file-pdf',
        route: 'ods-to-pdf'
    },
    {
        id: 'pdf-to-csv',
        title: 'PDF to CSV',
        description: 'Extract data from PDF to CSV format.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-csv',
        route: 'pdf-to-csv'
    },
    {
        id: 'pdf-to-excel',
        title: 'PDF to Excel',
        description: 'Extract data from PDF to Excel format.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-excel',
        route: 'pdf-to-excel'
    },
    {
        id: 'pdf-to-word',
        title: 'PDF to Word',
        description: 'Convert PDF documents to editable Word files.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-word',
        route: 'pdf-to-word'
    },
    {
        id: 'pdf-to-jpg',
        title: 'PDF to JPG',
        description: 'Convert PDF pages to JPG images.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-image',
        route: 'pdf-to-jpg'
    },
    {
        id: 'pdf-to-png',
        title: 'PDF to PNG',
        description: 'Convert PDF pages to PNG images.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-image',
        route: 'pdf-to-png'
    },
    {
        id: 'pdf-to-tiff',
        title: 'PDF to TIFF',
        description: 'Convert PDF documents to TIFF format.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-image',
        route: 'pdf-to-tiff'
    },
    {
        id: 'pdf-to-svg',
        title: 'PDF to SVG',
        description: 'Convert PDF pages to SVG vectors.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-bezier-curve',
        route: 'pdf-to-svg'
    },
    {
        id: 'pdf-to-html',
        title: 'PDF to HTML',
        description: 'Convert PDF documents to HTML pages.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-code',
        route: 'pdf-to-html'
    },
    {
        id: 'pdf-to-text',
        title: 'PDF to Text',
        description: 'Extract plain text from PDF documents.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-font',
        route: 'pdf-to-text'
    },
    {
        id: 'merge-pdf',
        title: 'Merge PDFs',
        description: 'Combine multiple PDF files into one.',
        sourceIcon: 'fas fa-copy',
        targetIcon: 'fas fa-file-pdf',
        route: 'merge-pdf'
    },
    {
        id: 'split-pdf',
        title: 'Split PDF',
        description: 'Split a PDF into individual pages.',
        sourceIcon: 'fas fa-cut',
        targetIcon: 'fas fa-file-pdf',
        route: 'split-pdf'
    },
    {
        id: 'compress-pdf',
        title: 'Compress PDF',
        description: 'Reduce the file size of your PDF documents.',
        sourceIcon: 'fas fa-compress-arrows-alt',
        targetIcon: 'fas fa-file-pdf',
        route: 'compress-pdf'
    },
    {
        id: 'remove-pages',
        title: 'Remove Pages',
        description: 'Remove specific pages from a PDF file.',
        sourceIcon: 'fas fa-trash-alt',
        targetIcon: 'fas fa-file-pdf',
        route: 'remove-pages'
    },
    {
        id: 'extract-pages',
        title: 'Extract Pages',
        description: 'Extract specific pages from a PDF to a new file.',
        sourceIcon: 'fas fa-file-export',
        targetIcon: 'fas fa-file-pdf',
        route: 'extract-pages'
    },
    {
        id: 'rotate-pdf',
        title: 'Rotate PDF',
        description: 'Rotate PDF pages permanently.',
        sourceIcon: 'fas fa-sync-alt',
        targetIcon: 'fas fa-file-pdf',
        route: 'rotate-pdf'
    },
    {
        id: 'add-watermark',
        title: 'Add Watermark',
        description: 'Add text or image watermarks to your PDF.',
        sourceIcon: 'fas fa-stamp',
        targetIcon: 'fas fa-file-pdf',
        route: 'add-watermark'
    },
    {
        id: 'add-page-numbers',
        title: 'Add Page Numbers',
        description: 'Add page numbers to your PDF documents.',
        sourceIcon: 'fas fa-list-ol',
        targetIcon: 'fas fa-file-pdf',
        route: 'add-page-numbers'
    },
    {
        id: 'crop-pdf',
        title: 'Crop PDF',
        description: 'Crop pages in your PDF documents.',
        sourceIcon: 'fas fa-crop',
        targetIcon: 'fas fa-file-pdf',
        route: 'crop-pdf'
    },
    {
        id: 'protect-pdf',
        title: 'Protect PDF',
        description: 'Encrypt your PDF with a password.',
        sourceIcon: 'fas fa-lock',
        targetIcon: 'fas fa-file-pdf',
        route: 'protect-pdf'
    },
    {
        id: 'unlock-pdf',
        title: 'Unlock PDF',
        description: 'Remove password protection from PDF files.',
        sourceIcon: 'fas fa-unlock',
        targetIcon: 'fas fa-file-pdf',
        route: 'unlock-pdf'
    },
    {
        id: 'repair-pdf',
        title: 'Repair PDF',
        description: 'Repair damaged or corrupted PDF files.',
        sourceIcon: 'fas fa-tools',
        targetIcon: 'fas fa-file-pdf',
        route: 'repair-pdf'
    },
    {
        id: 'compare-pdfs',
        title: 'Compare PDFs',
        description: 'Compare two PDF files for differences.',
        sourceIcon: 'fas fa-not-equal',
        targetIcon: 'fas fa-file-pdf',
        route: 'compare-pdfs'
    },
    {
        id: 'pdf-metadata',
        title: 'PDF Metadata',
        description: 'View and edit PDF metadata.',
        sourceIcon: 'fas fa-info-circle',
        targetIcon: 'fas fa-file-pdf',
        route: 'pdf-metadata'
    }
];
