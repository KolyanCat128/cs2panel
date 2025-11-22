import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiResponse } from '../../common/dto/api-response'; // Assuming a common ApiResponse DTO
import { VirtualMachine } from '../../common/models/virtual-machine'; // Assuming a common VirtualMachine model

@Injectable({
  providedIn: 'root',
})
export class VmService {
  private http = inject(HttpClient);
  private readonly API_URL = '/api/v1/vms';

  getAllVms(): Observable<ApiResponse<VirtualMachine[]>> {
    return this.http.get<ApiResponse<VirtualMachine[]>>(this.API_URL);
  }

  getVmById(id: number): Observable<ApiResponse<VirtualMachine>> {
    return this.http.get<ApiResponse<VirtualMachine>>(`${this.API_URL}/${id}`);
  }

  createVm(vm: VirtualMachine): Observable<ApiResponse<VirtualMachine>> {
    return this.http.post<ApiResponse<VirtualMachine>>(this.API_URL, vm);
  }

  startVm(id: number): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${this.API_URL}/${id}/start`, {});
  }

  stopVm(id: number): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${this.API_URL}/${id}/stop`, {});
  }

  rebootVm(id: number): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${this.API_URL}/${id}/reboot`, {});
  }

  deleteVm(id: number): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.API_URL}/${id}`);
  }
}
