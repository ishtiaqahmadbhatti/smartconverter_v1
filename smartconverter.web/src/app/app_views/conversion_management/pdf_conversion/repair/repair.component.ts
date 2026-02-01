import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-repair',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './repair.component.html',
  styleUrl: './repair.component.css',
  standalone: true
})
export class RepairComponent extends BasePdfToolComponent {
  toolId = 'repair';
}
