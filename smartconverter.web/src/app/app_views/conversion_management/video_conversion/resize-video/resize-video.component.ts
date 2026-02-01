import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseVideoToolComponent } from '../base-video-tool.component';

@Component({
  selector: 'app-resize-video',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './resize-video.component.html',
  styleUrl: './resize-video.component.css',
  standalone: true
})
export class ResizeVideoComponent extends BaseVideoToolComponent {
  toolId = 'resize-video';
}
