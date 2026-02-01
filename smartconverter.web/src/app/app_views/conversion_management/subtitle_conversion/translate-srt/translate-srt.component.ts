import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseSubtitleToolComponent } from '../base-subtitle-tool.component';

@Component({
  selector: 'app-translate-srt',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './translate-srt.component.html',
  styleUrl: './translate-srt.component.css',
  standalone: true
})
export class TranslateSrtComponent extends BaseSubtitleToolComponent {
  toolId = 'translate-srt';
}
