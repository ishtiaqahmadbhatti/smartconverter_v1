import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseAudioToolComponent } from '../base-audio-tool.component';

@Component({
  selector: 'app-convert-audio-format',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './convert-audio-format.component.html',
  styleUrl: './convert-audio-format.component.css',
  standalone: true
})
export class ConvertAudioFormatComponent extends BaseAudioToolComponent {
  toolId = 'convert-audio-format';
}
