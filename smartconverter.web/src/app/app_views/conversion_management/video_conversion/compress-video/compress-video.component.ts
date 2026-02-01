import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseVideoToolComponent } from '../base-video-tool.component';

@Component({
  selector: 'app-compress-video',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './compress-video.component.html',
  styleUrl: './compress-video.component.css',
  standalone: true
})
export class CompressVideoComponent extends BaseVideoToolComponent {
  toolId = 'compress-video';
}
