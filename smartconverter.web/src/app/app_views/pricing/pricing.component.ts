import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PRICING_DATA } from '../../app_data/pricing.data';
import { AuthService } from '../../app_services/auth.service';
import { Router } from '@angular/router';

@Component({
    selector: 'app-pricing',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './pricing.component.html',
    styleUrls: ['./pricing.component.css']
})
export class PricingComponent {
    plans = PRICING_DATA;
    currentPlanId = 'free'; // Default to free, normally fetched from auth/subscription provider

    constructor(public authService: AuthService, private router: Router) {
        // In a real app, subscribe to user subscription status here
        // this.subscriptionService.currentPlan$.subscribe(...)
    }

    selectPlan(planId: string) {
        if (this.currentPlanId === planId) return;

        // Check auth
        /* 
        if (!this.authService.isLoggedIn) {
            this.router.navigate(['/authentication/signin']);
            return;
        }
        */
        // For now, simplifed:
        console.log('Selected plan:', planId);
    }
}
