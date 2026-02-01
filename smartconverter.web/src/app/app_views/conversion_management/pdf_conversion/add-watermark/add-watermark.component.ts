import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-add-watermark',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './add-watermark.component.html',
  styleUrl: './add-watermark.component.css',
  standalone: true
})
export class AddWatermarkComponent extends BasePdfToolComponent {
  toolId = 'add-watermark';
}
