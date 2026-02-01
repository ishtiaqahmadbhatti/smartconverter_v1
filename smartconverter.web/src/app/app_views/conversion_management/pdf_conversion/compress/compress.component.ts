import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-compress',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './compress.component.html',
  styleUrl: './compress.component.css',
  standalone: true
})
export class CompressComponent extends BasePdfToolComponent {
  toolId = 'compress';
}
