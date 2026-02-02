export const PRICING_DATA = [
    {
        title: 'FREE',
        price: '$0',
        period: null, // No period for free
        subtitle: 'Perfect for casual use',
        features: [
            '5 Daily Conversions',
            '50MB Max File Size',
            'Basic Tools Access',
            'Watch Ads for More Conversions'
        ],
        icon: 'fa-solid fa-bolt', // Similar to flash_on
        color: '#A0AEC0', // AppColors.textTertiary approximate
        isPopular: false,
        planId: 'free',
        buttonText: 'Current Plan' // Logic will handle this text dynamically usually, but good to have default
    },
    {
        title: 'MONTHLY',
        price: '$3',
        period: '/month',
        subtitle: 'Ideal for power users',
        features: [
            '100 Daily Conversions',
            '200MB Max File Size',
            'Ad-Free Experience',
            'Priority Support',
            'All Premium Tools'
        ],
        icon: 'fa-solid fa-wand-magic-sparkles', // Similar to auto_awesome
        color: '#448aff', // AppColors.primaryBlue
        isPopular: true,
        planId: 'monthly',
        buttonText: 'Get Started'
    },
    {
        title: 'YEARLY',
        price: '$50',
        period: '/year',
        subtitle: 'Ultimate value & freedom',
        features: [
            'Unlimited Conversions',
            'Unlimited File Size',
            'Ad-Free Experience',
            'VIP Priority Support',
            'Full Cloud Integration'
        ],
        icon: 'fa-solid fa-crown', // Similar to workspace_premium
        color: '#00c853', // AppColors.secondaryGreen
        isPopular: false,
        planId: 'yearly',
        buttonText: 'Select Plan'
    }
];
