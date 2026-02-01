import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-metadata',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './metadata.component.html',
  styleUrl: './metadata.component.css',
  standalone: true
})
export class MetadataComponent extends BasePdfToolComponent {
  toolId = 'metadata';
}
