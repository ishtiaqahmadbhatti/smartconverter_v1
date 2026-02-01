import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-file-conversion-ui',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './file-conversion-ui.component.html',
    styleUrl: './file-conversion-ui.component.css'
})
export class FileConversionUiComponent {
    @Input() title: string = '';
    @Input() description: string = '';
    @Input() sourceIcon: string = 'fas fa-file';
    @Input() targetIcon: string = 'fas fa-file-alt';

    @Input() allowedExtensions: string = '*';
    @Input() allowedExtensionsText: string = '';
    @Input() convertButtonText: string = 'Convert';

    @Input() selectedFile: File | null = null;
    @Input() isConverting: boolean = false;
    @Input() conversionStatus: string = '';
    @Input() uploadProgress: number = 0;

    @Input() conversionResult: { downloadUrl: string, fileName: string } | null = null;

    @Output() fileSelected = new EventEmitter<File>();
    @Output() convert = new EventEmitter<void>();
    @Output() reset = new EventEmitter<void>();
    @Output() download = new EventEmitter<void>();

    onFileChange(event: any): void {
        const file = event.target.files[0];
        if (file) {
            this.fileSelected.emit(file);
        }
    }
}
