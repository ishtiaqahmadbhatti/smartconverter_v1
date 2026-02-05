import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../../app_services/auth.service';
import Swal from 'sweetalert2';
import { PRICING_DATA } from '../../../../app_data/pricing.data';

@Component({
    selector: 'app-subscription',
    templateUrl: './subscription.component.html',
    styleUrl: './subscription.component.css',
    standalone: true,
    imports: [CommonModule]
})
export class SubscriptionComponent implements OnInit {
    currentPlan = 'free';
    isLoading = false;
    plans = PRICING_DATA;

    constructor(private authService: AuthService) { }

    ngOnInit() {
        this.authService.getSubscriptionStatus().subscribe({
            next: (res) => {
                if (res && res.plan) {
                    this.currentPlan = res.plan.toLowerCase();
                }
            },
            error: (err) => console.error('Failed to get subscription', err)
        });
    }

    upgrade(plan: string) {
        Swal.fire({
            title: `Upgrade to ${plan}?`,
            text: "This will redirect you to the payment gateway.",
            icon: 'info',
            showCancelButton: true,
            confirmButtonText: 'Yes, Upgrade',
            confirmButtonColor: '#667eea'
        }).then((result) => {
            if (result.isConfirmed) {
                this.isLoading = true;
                // Mocking upgrade for now as payment gateway isn't fully defined
                setTimeout(() => {
                    this.isLoading = false;
                    Swal.fire('Success', `You have upgraded to ${plan}!`, 'success');
                    this.currentPlan = plan;
                }, 2000);

                /* 
                this.authService.upgradeSubscription(plan).subscribe({
                    next: (res) => { ... },
                    error: (err) => { ... }
                })
                */
            }
        });
    }
}
