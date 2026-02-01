import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseAudioToolComponent } from '../base-audio-tool.component';

@Component({
  selector: 'app-trim-audio',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './trim-audio.component.html',
  styleUrl: './trim-audio.component.css',
  standalone: true
})
export class TrimAudioComponent extends BaseAudioToolComponent {
  toolId = 'trim-audio';
}
