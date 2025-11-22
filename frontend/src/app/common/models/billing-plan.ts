export interface BillingPlan {
  id: number;
  name: string;
  description: string;
  price: number;
  currency: string;
  billingCycle: string;
  cpuCores: number;
  memoryMb: number;
  diskGb: number;
  active: boolean;
}
