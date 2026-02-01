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

  tools = [
    { name: 'JSON Conversion', icon: 'fas fa-database', link: '/jsonconversion', type: 'route' },
    { name: 'XML Conversion', icon: 'fas fa-code', link: '#xml', type: 'anchor' },
    { name: 'CSV Conversion', icon: 'fas fa-table', link: '#csv', type: 'anchor' },
    { name: 'Office Documents', icon: 'fas fa-file-word', link: '#office', type: 'anchor' },
    { name: 'PDF Conversion', icon: 'fas fa-file-pdf', link: '/pdfconversion', type: 'route' },
    { name: 'Image Conversion', icon: 'fas fa-image', link: '#image', type: 'anchor' },
    { name: 'OCR Conversion', icon: 'fas fa-file-alt', link: '#ocr', type: 'anchor' },
    { name: 'Website Conversion', icon: 'fas fa-globe', link: '#website', type: 'anchor' },
    { name: 'Video Conversion', icon: 'fas fa-video', link: '#video', type: 'anchor' },
    { name: 'Audio Conversion', icon: 'fas fa-music', link: '#audio', type: 'anchor' },
    { name: 'Subtitle Conversion', icon: 'fas fa-closed-captioning', link: '#subtitle', type: 'anchor' },
    { name: 'Text Conversion', icon: 'fas fa-font', link: '#text', type: 'anchor' },
    { name: 'eBook Conversion', icon: 'fas fa-book', link: '#ebook', type: 'anchor' },
    { name: 'File Formatter', icon: 'fas fa-wrench', link: '#formatter', type: 'anchor' }
  ];

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
