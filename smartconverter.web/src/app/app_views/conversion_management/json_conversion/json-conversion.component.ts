import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

import { JSON_CONVERSION_TOOLS } from '../../../app_data/json-conversion-tools.data';
import { ConversionTool } from '../../../app_models/conversion-tool.model';
import { ConversionToolsDashboardComponent } from '../../../app_shared/conversion-tools-dashboard/conversion-tools-dashboard.component';

@Component({
    selector: 'app-json-conversion',
    standalone: true,
    imports: [CommonModule, ConversionToolsDashboardComponent],
    templateUrl: './json-conversion.component.html',
    styleUrl: './json-conversion.component.css'
})
export class JsonConversionComponent {
    jsonconversiontools: ConversionTool[] = JSON_CONVERSION_TOOLS;
}
