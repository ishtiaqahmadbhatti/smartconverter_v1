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
    { name: 'XML Conversion', icon: 'fas fa-code', link: '/xmlconversion', type: 'route' },
    { name: 'CSV Conversion', icon: 'fas fa-table', link: '/csvconversion', type: 'route' },
    { name: 'Office Documents', icon: 'fas fa-file-word', link: '/officeconversion', type: 'route' },
    { name: 'PDF Conversion', icon: 'fas fa-file-pdf', link: '/pdfconversion', type: 'route' },
    { name: 'Image Conversion', icon: 'fas fa-image', link: '/imageconversion', type: 'route' },
    { name: 'OCR Conversion', icon: 'fas fa-file-alt', link: '/ocrconversion', type: 'route' },
    { name: 'Website Conversion', icon: 'fas fa-globe', link: '/websiteconversion', type: 'route' },
    { name: 'Video Conversion', icon: 'fas fa-video', link: '/videoconversion', type: 'route' },
    { name: 'Audio Conversion', icon: 'fas fa-music', link: '/audioconversion', type: 'route' },
    { name: 'Subtitle Conversion', icon: 'fas fa-closed-captioning', link: '/subtitleconversion', type: 'route' },
    { name: 'Text Conversion', icon: 'fas fa-font', link: '/textconversion', type: 'route' },
    { name: 'eBook Conversion', icon: 'fas fa-book', link: '/ebookconversion', type: 'route' },
    { name: 'File Formatter', icon: 'fas fa-wrench', link: '/fileformatter', type: 'route' }
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
