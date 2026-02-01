import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-unlock',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './unlock.component.html',
  styleUrl: './unlock.component.css',
  standalone: true
})
export class UnlockComponent extends BasePdfToolComponent {
  toolId = 'unlock';
}
