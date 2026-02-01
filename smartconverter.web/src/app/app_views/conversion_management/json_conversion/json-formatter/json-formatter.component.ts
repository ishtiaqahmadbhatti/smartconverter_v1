import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseJsonToolComponent } from '../base-json-tool.component';

@Component({
  selector: 'app-json-formatter',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './json-formatter.component.html',
  styleUrl: './json-formatter.component.css',
  standalone: true
})
export class JsonFormatterComponent extends BaseJsonToolComponent {
  toolId = 'json-formatter';
}
