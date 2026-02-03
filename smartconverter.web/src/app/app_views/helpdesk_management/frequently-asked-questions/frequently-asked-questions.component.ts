import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FAQ_DATA } from '../../../app_data/frequently-asked-questions.data';

import { RouterLink } from '@angular/router';

@Component({
    selector: 'app-frequently-asked-questions',
    standalone: true,
    imports: [CommonModule, RouterLink],
    templateUrl: './frequently-asked-questions.component.html',
    styleUrl: './frequently-asked-questions.component.css'
})
export class FrequentlyAskedQuestionsComponent {
    faqData = FAQ_DATA;
    openCategoryIndex: number = 0; // Default first category open
    openQuestionIndex: number | null = null; // Default no question open in category

    toggleCategory(index: number) {
        if (this.openCategoryIndex === index) {
            // Keep category open, maybe creating accordion effect for categories too? 
            // For now, let's just switch categories.
        } else {
            this.openCategoryIndex = index;
            this.openQuestionIndex = null; // Reset question when switching category
        }
    }

    toggleQuestion(index: number) {
        if (this.openQuestionIndex === index) {
            this.openQuestionIndex = null;
        } else {
            this.openQuestionIndex = index;
        }
    }
}
