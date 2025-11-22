export interface VirtualMachine {
  id: number;
  uuid: string;
  name: string;
  status: string;
  cpuCores: number;
  memoryMb: number;
  diskGb: number;
  osType: string;
  ipAddress: string;
  createdAt: string;
  // Add other fields from the backend entity as needed
}
