import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BasePdfToolComponent } from '../base-pdf-tool.component';

@Component({
  selector: 'app-protect',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './protect.component.html',
  styleUrl: './protect.component.css',
  standalone: true
})
export class ProtectComponent extends BasePdfToolComponent {
  toolId = 'protect';
}
