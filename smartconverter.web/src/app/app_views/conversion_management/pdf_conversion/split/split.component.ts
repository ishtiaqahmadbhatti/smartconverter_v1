import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-split',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './split.component.html',
  styleUrl: './split.component.css',
  standalone: true
})
export class SplitComponent extends BasePdfToolComponent {
  toolId = 'split';
}
