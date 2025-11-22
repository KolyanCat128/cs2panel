import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NodeListPage } from './node-list-page';

describe('NodeListPage', () => {
  let component: NodeListPage;
  let fixture: ComponentFixture<NodeListPage>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NodeListPage]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NodeListPage);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
