import { Component, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';

import { RouterModule } from '@angular/router';
import { AuthService } from '../../app_services/auth.service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrl: './header.component.css',
  standalone: true,
  imports: [CommonModule, RouterModule]
})

export class HeaderComponent {
  isScrolled = false;
  isMobileMenuOpen = false;
  showDropdown = false;
  showProfileDropdown = false;

  constructor(public authService: AuthService) { }

  @HostListener('window:scroll', [])
  onWindowScroll() {
    this.isScrolled = window.scrollY > 50;
  }

  toggleMobileMenu() {
    this.isMobileMenuOpen = !this.isMobileMenuOpen;
  }

  logout() {
    this.authService.logout();
    this.showProfileDropdown = false;
    this.isMobileMenuOpen = false;
  }
}
