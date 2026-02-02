import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CONTACT_US_DATA } from '../../app_data/contact-us.data';

@Component({
    selector: 'app-contact-us',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './contact_us.component.html',
    styleUrls: ['./contact_us.component.css']
})
export class ContactUsComponent {
    data = CONTACT_US_DATA;
    openFaqIndex: number | null = null;

    toggleFaq(index: number) {
        if (this.openFaqIndex === index) {
            this.openFaqIndex = null;
        } else {
            this.openFaqIndex = index;
        }
    }

    sendFeedback() {
        window.location.href = `mailto:${this.data.feedback.email}?subject=Smart Converter Feedback`;
    }
}
