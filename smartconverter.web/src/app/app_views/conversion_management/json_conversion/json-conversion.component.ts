import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';

import { JSON_CONVERSION_TOOLS } from '../../../app_data/json-conversion-tools.data';
import { ConversionTool } from '../../../app_models/conversion-tool.model';

import { FormsModule } from '@angular/forms';

@Component({
    selector: 'app-json-conversion',
    standalone: true,
    imports: [CommonModule, RouterLink, FormsModule],
    templateUrl: './json-conversion.component.html',
    styleUrl: './json-conversion.component.css'
})
export class JsonConversionComponent {
    jsonconversiontools: ConversionTool[] = JSON_CONVERSION_TOOLS;
    searchTerm: string = '';

    get filteredTools(): ConversionTool[] {
        if (!this.searchTerm) {
            return this.jsonconversiontools;
        }
        const term = this.searchTerm.toLowerCase();
        return this.jsonconversiontools.filter(tool =>
            tool.title.toLowerCase().includes(term)
        );
    }
}
