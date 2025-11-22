import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NodeDetailsPage } from './node-details-page';

describe('NodeDetailsPage', () => {
  let component: NodeDetailsPage;
  let fixture: ComponentFixture<NodeDetailsPage>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NodeDetailsPage]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NodeDetailsPage);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
