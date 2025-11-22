import { Subscription } from './subscription';

export interface Invoice {
  id: number;
  invoiceNumber: string;
  subscription: Subscription;
  status: string;
  subtotal: number;
  tax: number;
  total: number;
  currency: string;
  dueDate: string;
  paidAt: string;
}
