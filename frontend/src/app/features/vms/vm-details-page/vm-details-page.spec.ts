import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VmDetailsPage } from './vm-details-page';

describe('VmDetailsPage', () => {
  let component: VmDetailsPage;
  let fixture: ComponentFixture<VmDetailsPage>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [VmDetailsPage]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VmDetailsPage);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
