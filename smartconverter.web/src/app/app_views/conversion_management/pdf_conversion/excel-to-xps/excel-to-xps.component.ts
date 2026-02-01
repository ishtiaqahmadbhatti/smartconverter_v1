import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-excel-to-xps',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './excel-to-xps.component.html',
  styleUrl: './excel-to-xps.component.css',
  standalone: true
})
export class ExcelToXpsComponent extends BasePdfToolComponent {
  toolId = 'excel-to-xps';
}
