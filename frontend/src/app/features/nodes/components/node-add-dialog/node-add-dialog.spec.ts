import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NodeAddDialog } from './node-add-dialog';

describe('NodeAddDialog', () => {
  let component: NodeAddDialog;
  let fixture: ComponentFixture<NodeAddDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NodeAddDialog]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NodeAddDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
