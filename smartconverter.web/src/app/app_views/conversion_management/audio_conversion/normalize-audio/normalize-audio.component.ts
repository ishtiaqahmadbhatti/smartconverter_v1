import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseAudioToolComponent } from '../base-audio-tool.component';

@Component({
  selector: 'app-normalize-audio',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './normalize-audio.component.html',
  styleUrl: './normalize-audio.component.css',
  standalone: true
})
export class NormalizeAudioComponent extends BaseAudioToolComponent {
  toolId = 'normalize-audio';
}
