import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseFileFormatterToolComponent } from '../base-file-formatter-tool.component';

@Component({
  selector: 'app-format-json',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './format-json.component.html',
  styleUrl: './format-json.component.css',
  standalone: true
})
export class FormatJsonComponent extends BaseFileFormatterToolComponent {
  toolId = 'format-json';
}
