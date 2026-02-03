import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import Swal from 'sweetalert2';

@Component({
    selector: 'app-technical-support',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule],
    templateUrl: './technical-support.component.html',
    styleUrl: './technical-support.component.css'
})
export class TechnicalSupportComponent {
    supportForm: FormGroup;
    submitted = false;
    selectedFile: File | null = null;
    selectedFileName: string = '';

    constructor(private fb: FormBuilder) {
        this.supportForm = this.fb.group({
            name: ['', Validators.required],
            email: ['', [Validators.required, Validators.email]],
            issueType: ['', Validators.required],
            description: ['', [Validators.required, Validators.minLength(20)]],
            attachment: [null]
        });
    }

    onFileChange(event: any) {
        const file = event.target.files[0];
        if (file) {
            this.selectedFile = file;
            this.selectedFileName = file.name;
        }
    }

    onSubmit() {
        this.submitted = true;
        if (this.supportForm.valid) {
            console.log('Support Ticket Submitted:', this.supportForm.value);

            Swal.fire({
                title: 'Ticket Submitted!',
                text: 'Support ticket created successfully! We will contact you soon.',
                icon: 'success',
                confirmButtonColor: '#667eea'
            });

            this.supportForm.reset();
            this.submitted = false;
        }
    }
}
