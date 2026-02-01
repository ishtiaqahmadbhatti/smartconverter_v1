import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseFileFormatterToolComponent } from '../base-file-formatter-tool.component';

@Component({
  selector: 'app-validate-xsd',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './validate-xsd.component.html',
  styleUrl: './validate-xsd.component.css',
  standalone: true
})
export class ValidateXsdComponent extends BaseFileFormatterToolComponent {
  toolId = 'validate-xsd';
}
