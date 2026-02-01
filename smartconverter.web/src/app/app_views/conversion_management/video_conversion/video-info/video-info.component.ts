import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseVideoToolComponent } from '../base-video-tool.component';

@Component({
  selector: 'app-video-info',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './video-info.component.html',
  styleUrl: './video-info.component.css',
  standalone: true
})
export class VideoInfoComponent extends BaseVideoToolComponent {
  toolId = 'video-info';
}
