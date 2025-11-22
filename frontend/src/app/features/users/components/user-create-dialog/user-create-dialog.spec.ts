import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserCreateDialog } from './user-create-dialog';

describe('UserCreateDialog', () => {
  let component: UserCreateDialog;
  let fixture: ComponentFixture<UserCreateDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserCreateDialog]
    })
    .compileComponents();

    fixture = TestBed.createComponent(UserCreateDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
