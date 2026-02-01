import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-pdf-to-excel-ai',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './pdf-to-excel-ai.component.html',
  styleUrl: './pdf-to-excel-ai.component.css',
  standalone: true
})
export class PdfToExcelAiComponent extends BasePdfToolComponent {
  toolId = 'pdf-to-excel-ai';
}
