import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseFileFormatterToolComponent } from '../base-file-formatter-tool.component';

@Component({
  selector: 'app-validate-xml',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './validate-xml.component.html',
  styleUrl: './validate-xml.component.css',
  standalone: true
})
export class ValidateXmlComponent extends BaseFileFormatterToolComponent {
  toolId = 'validate-xml';
}
