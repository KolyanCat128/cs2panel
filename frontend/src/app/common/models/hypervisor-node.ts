export interface HypervisorNode {
  id: number;
  name: string;
  hostname: string;
  ipAddress: string;
  port: number;
  status: string;
  cpuCores: number;
  cpuUsed: number;
  memoryTotalMb: number;
  memoryUsedMb: number;
  diskTotalGb: number;
  diskUsedGb: number;
  enabled: boolean;
  createdAt: string;
}
