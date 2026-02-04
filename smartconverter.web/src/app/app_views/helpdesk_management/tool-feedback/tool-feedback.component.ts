import { Component, ElementRef, HostListener, ViewChild, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import Swal from 'sweetalert2';

// Import all tool data
import { PDF_CONVERSION_TOOLS } from '../../../app_data/pdf-conversion-tools.data';
import { IMAGE_CONVERSION_TOOLS } from '../../../app_data/image-conversion-tools.data';
import { AUDIO_CONVERSION_TOOLS } from '../../../app_data/audio-conversion-tools.data';
import { VIDEO_CONVERSION_TOOLS } from '../../../app_data/video-conversion-tools.data';
import { OFFICE_CONVERSION_TOOLS } from '../../../app_data/office-conversion-tools.data';
import { EBOOK_CONVERSION_TOOLS } from '../../../app_data/ebook-conversion-tools.data';
import { JSON_CONVERSION_TOOLS } from '../../../app_data/json-conversion-tools.data';
import { XML_CONVERSION_TOOLS } from '../../../app_data/xml-conversion-tools.data';
import { CSV_CONVERSION_TOOLS } from '../../../app_data/csv-conversion-tools.data';
import { TEXT_CONVERSION_TOOLS } from '../../../app_data/text-conversion-tools.data';
import { OCR_CONVERSION_TOOLS } from '../../../app_data/ocr-conversion-tools.data';
import { WEBSITE_CONVERSION_TOOLS } from '../../../app_data/website-conversion-tools.data';
import { SUBTITLE_CONVERSION_TOOLS } from '../../../app_data/subtitle-conversion-tools.data';
import { FILE_FORMATTER_TOOLS } from '../../../app_data/file-formatter-tools.data';

@Component({
    selector: 'app-tool-feedback',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule],
    templateUrl: './tool-feedback.component.html',
    styleUrl: './tool-feedback.component.css'
})
export class ToolFeedbackComponent implements OnInit {
    feedbackForm: FormGroup;
    submitted = false;
    ratings = [1, 2, 3, 4, 5];
    isLocked = false;

    // Tool Categories
    toolCategories: any[] = [
        { name: 'PDF Conversion', tools: PDF_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Image Conversion', tools: IMAGE_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Audio Conversion', tools: AUDIO_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Video Conversion', tools: VIDEO_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Office Conversion', tools: OFFICE_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'E-Book Conversion', tools: EBOOK_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'JSON Conversion', tools: JSON_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'XML Conversion', tools: XML_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'CSV Conversion', tools: CSV_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Text Conversion', tools: TEXT_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'OCR Conversion', tools: OCR_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Website Conversion', tools: WEBSITE_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'Subtitle Conversion', tools: SUBTITLE_CONVERSION_TOOLS.map(t => t.title) },
        { name: 'File Formatter', tools: FILE_FORMATTER_TOOLS.map(t => t.title) }
    ];

    selectedTools: string[] = [];
    isCategoryDropdownOpen = false;
    isToolDropdownOpen = false;

    constructor(
        private fb: FormBuilder,
        private eRef: ElementRef,
        private route: ActivatedRoute
    ) {
        this.feedbackForm = this.fb.group({
            name: ['', Validators.required],
            email: ['', [Validators.required, Validators.email]],
            category: ['', Validators.required],
            tool: ['', Validators.required],
            rating: [null, Validators.required],
            message: ['', [Validators.required, Validators.minLength(10)]]
        });
    }

    ngOnInit(): void {
        this.route.queryParams.subscribe(params => {
            const toolName = params['tool'];
            if (toolName) {
                this.autoSelectTool(toolName);
            } else {
                this.resetSelection();
            }
        });
    }

    autoSelectTool(toolName: string) {
        // Find category containing his tool
        const matchedCategory = this.toolCategories.find(cat => cat.tools.includes(toolName));

        if (matchedCategory) {
            this.isLocked = true;
            this.selectedTools = matchedCategory.tools;

            this.feedbackForm.patchValue({
                category: matchedCategory.name,
                tool: toolName
            });
        }
    }

    resetSelection() {
        this.isLocked = false;
        this.selectedTools = [];
        this.isCategoryDropdownOpen = false;
        this.isToolDropdownOpen = false;

        // Only reset category and tool if form was touched or populated
        // This prevents blowing away user input if they just navigated around? 
        // Actually, matching user expectation: if they click "Tool Feedback" footer, they expect a fresh form.
        this.feedbackForm.patchValue({
            category: '',
            tool: ''
        });
    }

    toggleCategoryDropdown() {
        if (this.isLocked) return;
        this.isCategoryDropdownOpen = !this.isCategoryDropdownOpen;
        this.isToolDropdownOpen = false;
    }

    toggleToolDropdown() {
        if (this.isLocked) return;
        if (this.selectedTools.length > 0) {
            this.isToolDropdownOpen = !this.isToolDropdownOpen;
            this.isCategoryDropdownOpen = false;
        }
    }

    selectCategory(categoryName: string) {
        if (this.isLocked) return;
        this.feedbackForm.patchValue({ category: categoryName });
        const category = this.toolCategories.find(c => c.name === categoryName);
        this.selectedTools = category ? category.tools : [];
        this.feedbackForm.patchValue({ tool: '' }); // Reset tool
        this.isCategoryDropdownOpen = false;
    }

    selectTool(toolName: string) {
        if (this.isLocked) return;
        this.feedbackForm.patchValue({ tool: toolName });
        this.isToolDropdownOpen = false;
    }

    @HostListener('document:click', ['$event'])
    clickout(event: any) {
        if (!this.eRef.nativeElement.contains(event.target)) {
            this.isCategoryDropdownOpen = false;
            this.isToolDropdownOpen = false;
        }
    }

    setRating(rating: number) {
        this.feedbackForm.patchValue({ rating });
    }

    onSubmit() {
        this.submitted = true;
        if (this.feedbackForm.valid) {
            console.log('Tool Feedback Submitted:', this.feedbackForm.value);

            Swal.fire({
                title: 'Feedback Received!',
                text: 'Thank you for helping us improve our tools!',
                icon: 'success',
                confirmButtonColor: '#667eea'
            });

            this.feedbackForm.reset();
            this.selectedTools = [];
            this.submitted = false;
        }
    }
}
