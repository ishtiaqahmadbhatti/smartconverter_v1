import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseVideoToolComponent } from '../base-video-tool.component';

@Component({
  selector: 'app-video-to-audio',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './video-to-audio.component.html',
  styleUrl: './video-to-audio.component.css',
  standalone: true
})
export class VideoToAudioComponent extends BaseVideoToolComponent {
  toolId = 'video-to-audio';
}
