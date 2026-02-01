import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseAudioToolComponent } from '../base-audio-tool.component';

@Component({
  selector: 'app-audio-info',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './audio-info.component.html',
  styleUrl: './audio-info.component.css',
  standalone: true
})
export class AudioInfoComponent extends BaseAudioToolComponent {
  toolId = 'audio-info';
}
