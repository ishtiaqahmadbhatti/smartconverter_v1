import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseVideoToolComponent } from '../base-video-tool.component';

@Component({
  selector: 'app-extract-audio',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './extract-audio.component.html',
  styleUrl: './extract-audio.component.css',
  standalone: true
})
export class ExtractAudioComponent extends BaseVideoToolComponent {
  toolId = 'extract-audio';
}
