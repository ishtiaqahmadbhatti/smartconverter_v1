import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';

import { PDF_CONVERSION_TOOLS } from '../../../app_data/pdf-conversion-tools.data';
import { ConversionTool } from '../../../app_models/conversion-tool.model';

@Component({
    selector: 'app-pdf-conversion',
    standalone: true,
    imports: [CommonModule, RouterLink, FormsModule],
    templateUrl: './pdf-conversion.component.html',
    styleUrl: './pdf-conversion.component.css'
})
export class PdfConversionComponent {
    pdfconversiontools: ConversionTool[] = PDF_CONVERSION_TOOLS;
    searchTerm: string = '';

    get filteredTools(): ConversionTool[] {
        if (!this.searchTerm) {
            return this.pdfconversiontools;
        }
        const term = this.searchTerm.toLowerCase();
        return this.pdfconversiontools.filter(tool =>
            tool.title.toLowerCase().includes(term)
        );
    }
}
