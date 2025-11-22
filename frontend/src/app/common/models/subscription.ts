import { BillingPlan } from './billing-plan';

export interface Subscription {
  id: number;
  plan: BillingPlan;
  status: string;
  startDate: string;
  endDate: string;
  autoRenew: boolean;
}
