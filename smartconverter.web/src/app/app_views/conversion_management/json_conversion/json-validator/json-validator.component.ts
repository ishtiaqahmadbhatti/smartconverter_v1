import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseJsonToolComponent } from '../base-json-tool.component';

@Component({
  selector: 'app-json-validator',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './json-validator.component.html',
  styleUrl: './json-validator.component.css',
  standalone: true
})
export class JsonValidatorComponent extends BaseJsonToolComponent {
  toolId = 'json-validator';
}
