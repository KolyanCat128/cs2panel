import { TestBed } from '@angular/core/testing';

import { Vm } from './vm';

describe('Vm', () => {
  let service: Vm;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Vm);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
