import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseImageToolComponent } from '../base-image-tool.component';

@Component({
  selector: 'app-html-to-jpg',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './html-to-jpg.component.html',
  styleUrl: './html-to-jpg.component.css',
  standalone: true
})
export class HtmlToJpgComponent extends BaseImageToolComponent {
  toolId = 'html-to-jpg';
}
