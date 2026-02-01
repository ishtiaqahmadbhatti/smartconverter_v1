import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-pdf-to-csv-ai',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './pdf-to-csv-ai.component.html',
  styleUrl: './pdf-to-csv-ai.component.css',
  standalone: true
})
export class PdfToCsvAiComponent extends BasePdfToolComponent {
  toolId = 'pdf-to-csv-ai';
}
