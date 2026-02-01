import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-crop',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './crop.component.html',
  styleUrl: './crop.component.css',
  standalone: true
})
export class CropComponent extends BasePdfToolComponent {
  toolId = 'crop';
}
