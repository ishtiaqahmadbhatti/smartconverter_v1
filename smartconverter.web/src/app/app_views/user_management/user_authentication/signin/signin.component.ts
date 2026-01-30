import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-signin',
  templateUrl: './signin.component.html',
  styleUrls: ['./signin.component.css'],
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule]
})
export class SigninComponent {
  signinForm: FormGroup;
  showPassword = false;
  isSubmitting = false;

  constructor(
    private fb: FormBuilder,
    private router: Router
  ) {
    this.signinForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  // Getters for form controls
  get email() { return this.signinForm.get('email'); }
  get password() { return this.signinForm.get('password'); }

  async onSubmit() {
    if (this.signinForm.invalid) {
      // Mark all fields as touched to show validation errors
      Object.keys(this.signinForm.controls).forEach(key => {
        this.signinForm.get(key)?.markAsTouched();
      });
      return;
    }

    this.isSubmitting = true;

    try {
      // TODO: Implement actual API call
      const formData = this.signinForm.value;
      console.log('Signin data:', formData);

      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Success - navigate to home or dashboard
      alert('Sign in successful!');
      this.router.navigate(['/']);
    } catch (error) {
      console.error('Signin error:', error);
      alert('Sign in failed. Please check your credentials.');
    } finally {
      this.isSubmitting = false;
    }
  }
}
