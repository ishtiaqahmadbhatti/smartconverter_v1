import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseVideoToolComponent } from '../base-video-tool.component';

@Component({
  selector: 'app-convert-video-format',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './convert-video-format.component.html',
  styleUrl: './convert-video-format.component.css',
  standalone: true
})
export class ConvertVideoFormatComponent extends BaseVideoToolComponent {
  toolId = 'convert-video-format';
}
