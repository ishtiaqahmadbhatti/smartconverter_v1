import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-merge',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './merge.component.html',
  styleUrl: './merge.component.css',
  standalone: true
})
export class MergeComponent extends BasePdfToolComponent {
  toolId = 'merge';
}
