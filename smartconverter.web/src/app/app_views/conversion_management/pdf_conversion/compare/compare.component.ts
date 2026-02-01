import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-compare',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './compare.component.html',
  styleUrl: './compare.component.css',
  standalone: true
})
export class CompareComponent extends BasePdfToolComponent {
  toolId = 'compare';
}
