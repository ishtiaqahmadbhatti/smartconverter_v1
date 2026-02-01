import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseFileFormatterToolComponent } from '../base-file-formatter-tool.component';

@Component({
  selector: 'app-validate-json',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './validate-json.component.html',
  styleUrl: './validate-json.component.css',
  standalone: true
})
export class ValidateJsonComponent extends BaseFileFormatterToolComponent {
  toolId = 'validate-json';
}
