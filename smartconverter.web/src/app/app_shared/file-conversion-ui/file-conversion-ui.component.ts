import { Component, EventEmitter, Input, Output, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

// Import tool data for category lookup
import { PDF_CONVERSION_TOOLS } from '../../app_data/pdf-conversion-tools.data';
import { IMAGE_CONVERSION_TOOLS } from '../../app_data/image-conversion-tools.data';
import { AUDIO_CONVERSION_TOOLS } from '../../app_data/audio-conversion-tools.data';
import { VIDEO_CONVERSION_TOOLS } from '../../app_data/video-conversion-tools.data';
import { OFFICE_CONVERSION_TOOLS } from '../../app_data/office-conversion-tools.data';
import { EBOOK_CONVERSION_TOOLS } from '../../app_data/ebook-conversion-tools.data';
import { JSON_CONVERSION_TOOLS } from '../../app_data/json-conversion-tools.data';
import { XML_CONVERSION_TOOLS } from '../../app_data/xml-conversion-tools.data';
import { CSV_CONVERSION_TOOLS } from '../../app_data/csv-conversion-tools.data';
import { TEXT_CONVERSION_TOOLS } from '../../app_data/text-conversion-tools.data';
import { OCR_CONVERSION_TOOLS } from '../../app_data/ocr-conversion-tools.data';
import { WEBSITE_CONVERSION_TOOLS } from '../../app_data/website-conversion-tools.data';
import { SUBTITLE_CONVERSION_TOOLS } from '../../app_data/subtitle-conversion-tools.data';
import { FILE_FORMATTER_TOOLS } from '../../app_data/file-formatter-tools.data';

@Component({
    selector: 'app-file-conversion-ui',
    standalone: true,
    imports: [CommonModule, RouterLink],
    templateUrl: './file-conversion-ui.component.html',
    styleUrl: './file-conversion-ui.component.css'
})
export class FileConversionUiComponent implements OnInit {
    @Input() title: string = '';
    @Input() description: string = '';
    @Input() sourceIcon: string = 'fas fa-file';
    @Input() targetIcon: string = 'fas fa-file-alt';

    @Input() allowedExtensions: string = '*';
    @Input() allowedExtensionsText: string = '';
    @Input() convertButtonText: string = 'Convert';

    @Input() selectedFile: File | null = null;
    @Input() isConverting: boolean = false;
    @Input() conversionStatus: string = '';
    @Input() uploadProgress: number = 0;

    @Input() conversionResult: { downloadUrl: string, fileName: string } | null = null;

    @Output() fileSelected = new EventEmitter<File>();
    @Output() convert = new EventEmitter<void>();
    @Output() reset = new EventEmitter<void>();
    @Output() download = new EventEmitter<void>();

    currentCategory: string = '';

    ngOnInit() {
        this.currentCategory = this.findCategoryForTool(this.title);
    }

    findCategoryForTool(toolTitle: string): string {
        // Map must match ToolFeedbackComponent category names exactly
        const categories = [
            { name: 'PDF Conversion', tools: PDF_CONVERSION_TOOLS },
            { name: 'Image Conversion', tools: IMAGE_CONVERSION_TOOLS },
            { name: 'Audio Conversion', tools: AUDIO_CONVERSION_TOOLS },
            { name: 'Video Conversion', tools: VIDEO_CONVERSION_TOOLS },
            { name: 'Office Conversion', tools: OFFICE_CONVERSION_TOOLS },
            { name: 'E-Book Conversion', tools: EBOOK_CONVERSION_TOOLS },
            { name: 'JSON Conversion', tools: JSON_CONVERSION_TOOLS },
            { name: 'XML Conversion', tools: XML_CONVERSION_TOOLS },
            { name: 'CSV Conversion', tools: CSV_CONVERSION_TOOLS },
            { name: 'Text Conversion', tools: TEXT_CONVERSION_TOOLS },
            { name: 'OCR Conversion', tools: OCR_CONVERSION_TOOLS },
            { name: 'Website Conversion', tools: WEBSITE_CONVERSION_TOOLS },
            { name: 'Subtitle Conversion', tools: SUBTITLE_CONVERSION_TOOLS },
            { name: 'File Formatter', tools: FILE_FORMATTER_TOOLS }
        ];

        for (const cat of categories) {
            if (cat.tools.some(t => t.title === toolTitle)) {
                return cat.name;
            }
        }
        return '';
    }

    onFileChange(event: any): void {
        const file = event.target.files[0];
        if (file) {
            this.fileSelected.emit(file);
        }
    }
}
