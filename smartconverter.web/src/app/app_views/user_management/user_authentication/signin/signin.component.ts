import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../../../app_services/auth.service';
import { ToastService } from '../../../../app_services/toast';

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
    private router: Router,
    private authService: AuthService,
    private toastService: ToastService
  ) {
    this.signinForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  // Getters for form controls
  get email() { return this.signinForm.get('email'); }
  get password() { return this.signinForm.get('password'); }

  onSubmit() {
    if (this.signinForm.invalid) {
      // Mark all fields as touched to show validation errors
      Object.keys(this.signinForm.controls).forEach(key => {
        this.signinForm.get(key)?.markAsTouched();
      });
      return;
    }

    this.isSubmitting = true;
    const credentials = this.signinForm.value;

    this.authService.login(credentials).subscribe({
      next: (response) => {
        this.isSubmitting = false;
        // Adjust based on actual API response structure. 
        // Mobile implies response has access_token and refresh_token directly.
        if (response && response.access_token) {
          // Construct full profile image URL if available
          let profileImageUrl = undefined;
          if (response.profile_image_url) {
            const baseUrl = 'http://192.168.8.100:8000'; // From ApplicationConfiguration
            const relativePath = response.profile_image_url.startsWith('/')
              ? response.profile_image_url.substring(1)
              : response.profile_image_url;
            profileImageUrl = `${baseUrl}/${relativePath}`;
          }

          this.authService.saveTokens(
            response.access_token,
            response.refresh_token,
            response.full_name || 'User',
            credentials.email,
            profileImageUrl
          );

          // Immediately fetch user profile to load image in header
          this.authService.getUserProfile().subscribe({
            next: (user) => {
              if (user.profile_image_url) {
                const baseUrl = 'http://192.168.8.100:8000';
                const relativePath = user.profile_image_url.startsWith('/')
                  ? user.profile_image_url.substring(1)
                  : user.profile_image_url;
                const fullUrl = `${baseUrl}/${relativePath}`;
                this.authService.updateProfileImage(fullUrl);
              }
            },
            error: (err) => console.error('Failed to load profile after login', err)
          });

          this.toastService.show('Sign in successful!', 'success');
          this.router.navigate(['/']);
        } else {
          console.error('Unexpected response structure:', response);
          this.toastService.show('Login succeeded but token missing. Please try again.', 'error');
        }
      },
      error: (err) => {
        this.isSubmitting = false;
        console.error('Signin error:', err);
        const errorMsg = err.error?.detail || err.error?.message || 'Sign in failed. Please check your credentials.';
        this.toastService.show(errorMsg, 'error');
      }
    });
  }
}
