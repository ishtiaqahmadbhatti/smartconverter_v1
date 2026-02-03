import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConversionToolsDetails } from './conversion-tools-details';

describe('ConversionToolsDetails', () => {
  let component: ConversionToolsDetails;
  let fixture: ComponentFixture<ConversionToolsDetails>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConversionToolsDetails]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ConversionToolsDetails);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
