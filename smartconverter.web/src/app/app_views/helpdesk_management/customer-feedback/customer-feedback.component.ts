import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import Swal from 'sweetalert2';

@Component({
    selector: 'app-customer-feedback',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule],
    templateUrl: './customer-feedback.component.html',
    styleUrl: './customer-feedback.component.css'
})
export class CustomerFeedbackComponent {
    feedbackForm: FormGroup;
    submitted = false;
    ratings = [1, 2, 3, 4, 5];
    selectedFile: File | null = null;
    selectedFileName: string = '';

    constructor(private fb: FormBuilder) {
        this.feedbackForm = this.fb.group({
            name: ['', Validators.required],
            email: ['', [Validators.required, Validators.email]],
            rating: [null, Validators.required],
            message: ['', [Validators.required, Validators.minLength(10)]],
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
        if (this.feedbackForm.valid) {
            console.log('Feedback Submitted:', this.feedbackForm.value);
            // Simulate API call
            Swal.fire({
                title: 'Thank You!',
                text: 'Your feedback has been submitted successfully!',
                icon: 'success',
                confirmButtonColor: '#9f7aea'
            });
            this.feedbackForm.reset();
            this.submitted = false;
        }
    }
    setRating(rating: number) {
        this.feedbackForm.patchValue({ rating });
    }
}
