import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseFileFormatterToolComponent } from '../base-file-formatter-tool.component';

@Component({
  selector: 'app-json-schema-info',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './json-schema-info.component.html',
  styleUrl: './json-schema-info.component.css',
  standalone: true
})
export class JsonSchemaInfoComponent extends BaseFileFormatterToolComponent {
  toolId = 'json-schema-info';
}
