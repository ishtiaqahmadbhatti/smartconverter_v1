import { Component } from '@angular/core';
import { ConvertService } from '../../../app_controllers/services.controller';
@Component({
  selector: 'app-pdf-to-word',
  templateUrl: './pdf-to-word.component.html',
  styleUrls: ['./pdf-to-word.component.css'],
  standalone: true,
  imports: []
})
export class PdfToWordComponent {
  selectedFile: File | null = null;
  
  constructor(private convertService: ConvertService) { }

  onFileSelected(event: any): void {
    this.selectedFile = event.target.files[0];
  }
  
  convertPdfToWord(): void {
    debugger;
    if (this.selectedFile) {
      this.convertService.convertPdfToWord(this.selectedFile).subscribe(response => {
        this.downloadFile(response, 'converted.docx');
      }, error => {
        console.error('Error converting PDF to Word:', error);
      });
    }
  }

  private downloadFile(data: Blob, filename: string): void {
    const url = window.URL.createObjectURL(data);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }

}
