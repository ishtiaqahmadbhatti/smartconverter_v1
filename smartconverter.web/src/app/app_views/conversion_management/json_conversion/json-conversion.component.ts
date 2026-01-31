import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-json-conversion',
    standalone: true,
    imports: [CommonModule, RouterLink],
    templateUrl: './json-conversion.component.html',
    styleUrl: './json-conversion.component.css'
})
export class JsonConversionComponent {
    tools = [
        {
            id: 'json-to-csv',
            title: 'JSON to CSV',
            description: 'Convert JSON data to Comma Separated Values (CSV) format.',
            sourceIcon: 'fas fa-file-code',
            targetIcon: 'fas fa-file-csv',
            route: 'json-to-csv'
        }
    ];
}
