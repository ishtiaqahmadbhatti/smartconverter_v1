import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { TERMS_OF_SERVICE_DATA } from '../../app_data/terms-of-service.data';

@Component({
    selector: 'app-terms-of-service',
    standalone: true,
    imports: [CommonModule, RouterLink],
    templateUrl: './terms_of_service.component.html',
    styleUrls: ['./terms_of_service.component.css']
})
export class TermsOfServiceComponent {
    currentYear = new Date().getFullYear();
    sections = TERMS_OF_SERVICE_DATA;
}
