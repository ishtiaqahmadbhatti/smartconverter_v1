import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import Swal from 'sweetalert2';

@Component({
    selector: 'app-contact-us',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule],
    templateUrl: './contact_us.component.html',
    styleUrl: './contact_us.component.css'
})
export class ContactUsComponent {
    contactForm: FormGroup;
    submitted = false;

    constructor(private fb: FormBuilder) {
        this.contactForm = this.fb.group({
            name: ['', Validators.required],
            email: ['', [Validators.required, Validators.email]],
            subject: ['', Validators.required],
            message: ['', Validators.required]
        });
    }

    onSubmit() {
        this.submitted = true;
        if (this.contactForm.valid) {
            console.log('Message sent:', this.contactForm.value);

            Swal.fire({
                title: 'Message Sent!',
                text: 'Thank you! Your message has been sent.',
                icon: 'success',
                confirmButtonColor: '#667eea'
            });

            this.contactForm.reset();
            this.submitted = false;
        }
    }
}
