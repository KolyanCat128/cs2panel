import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VmCreateDialog } from './vm-create-dialog';

describe('VmCreateDialog', () => {
  let component: VmCreateDialog;
  let fixture: ComponentFixture<VmCreateDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [VmCreateDialog]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VmCreateDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
