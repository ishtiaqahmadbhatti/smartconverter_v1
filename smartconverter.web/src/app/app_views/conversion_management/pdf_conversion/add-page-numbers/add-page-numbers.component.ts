import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-add-page-numbers',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './add-page-numbers.component.html',
  styleUrl: './add-page-numbers.component.css',
  standalone: true
})
export class AddPageNumbersComponent extends BasePdfToolComponent {
  toolId = 'add-page-numbers';
}
