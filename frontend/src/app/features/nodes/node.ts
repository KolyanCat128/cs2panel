import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiResponse } from '../../common/dto/api-response';
import { HypervisorNode } from '../../common/models/hypervisor-node'; // Assuming a common HypervisorNode model

@Injectable({
  providedIn: 'root',
})
export class NodeService {
  private http = inject(HttpClient);
  private readonly API_URL = '/api/v1/nodes';

  getAllNodes(): Observable<ApiResponse<HypervisorNode[]>> {
    return this.http.get<ApiResponse<HypervisorNode[]>>(this.API_URL);
  }

  getNodeById(id: number): Observable<ApiResponse<HypervisorNode>> {
    return this.http.get<ApiResponse<HypervisorNode>>(`${this.API_URL}/${id}`);
  }

  addNode(node: { name: string, ipAddress: string, port: number }): Observable<ApiResponse<HypervisorNode>> {
    return this.http.post<ApiResponse<HypervisorNode>>(this.API_URL, node);
  }

  deleteNode(id: number): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.API_URL}/${id}`);
  }
}
