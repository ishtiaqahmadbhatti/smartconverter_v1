import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseFileFormatterToolComponent } from '../base-file-formatter-tool.component';

@Component({
  selector: 'app-format-xml',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './format-xml.component.html',
  styleUrl: './format-xml.component.css',
  standalone: true
})
export class FormatXmlComponent extends BaseFileFormatterToolComponent {
  toolId = 'format-xml';
}
