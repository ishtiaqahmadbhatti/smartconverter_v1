import { Component, Input, computed, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ConversionTool } from '../../app_models/conversion-tool.model';

@Component({
    selector: 'app-conversion-tools-dashboard',
    standalone: true,
    imports: [CommonModule, RouterLink, FormsModule],
    templateUrl: './conversion-tools-dashboard.component.html',
    styleUrl: './conversion-tools-dashboard.component.css'
})
export class ConversionToolsDashboardComponent {
    @Input() tools: ConversionTool[] = [];
    @Input() title: string = '';
    @Input() description: string = '';
    @Input() searchPlaceholder: string = 'Search tools...';

    searchTerm = signal('');

    filteredTools = computed(() => {
        const term = this.searchTerm().toLowerCase();
        if (!term) return this.tools;

        return this.tools.filter(tool =>
            tool.title.toLowerCase().includes(term)
        );
    });
}
