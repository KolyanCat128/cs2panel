import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VmListPage } from './vm-list-page';

describe('VmListPage', () => {
  let component: VmListPage;
  let fixture: ComponentFixture<VmListPage>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [VmListPage]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VmListPage);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
