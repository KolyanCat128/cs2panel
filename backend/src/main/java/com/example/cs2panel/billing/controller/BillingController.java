package com.example.cs2panel.billing.controller;

import com.example.cs2panel.billing.entity.BillingPlan;
import com.example.cs2panel.billing.entity.Invoice;
import com.example.cs2panel.billing.service.BillingService;
import com.example.cs2panel.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/billing")
@RequiredArgsConstructor
@Tag(name = "Billing", description = "Billing and payment management")
public class BillingController {

    private final BillingService billingService;

    @GetMapping("/plans")
    @Operation(summary = "Get all billing plans")
    public ResponseEntity<ApiResponse<List<BillingPlan>>> getAllPlans() {
        List<BillingPlan> plans = billingService.getAllPlans();
        return ResponseEntity.ok(ApiResponse.success(plans, "Plans retrieved"));
    }

    @GetMapping("/plans/{id}")
    @Operation(summary = "Get plan by ID")
    public ResponseEntity<ApiResponse<BillingPlan>> getPlan(@PathVariable Long id) {
        BillingPlan plan = billingService.getPlanById(id);
        return ResponseEntity.ok(ApiResponse.success(plan, "Plan retrieved"));
    }

    @GetMapping("/invoices")
    @Operation(summary = "Get user invoices")
    public ResponseEntity<ApiResponse<List<Invoice>>> getUserInvoices() {
        Long userId = 1L; // Get from security context
        List<Invoice> invoices = billingService.getUserInvoices(userId);
        return ResponseEntity.ok(ApiResponse.success(invoices, "Invoices retrieved"));
    }

    @GetMapping("/invoices/{id}/pdf")
    @Operation(summary = "Download invoice PDF")
    public ResponseEntity<byte[]> downloadInvoicePdf(@PathVariable Long id) {
        byte[] pdf = billingService.generateInvoicePdf(id);
        return ResponseEntity.ok()
                .header("Content-Type", "application/pdf")
                .header("Content-Disposition", "attachment; filename=invoice-" + id + ".pdf")
                .body(pdf);
    }

    @PostMapping("/invoices/{id}/pay")
    @Operation(summary = "Mark invoice as paid")
    @PreAuthorize("hasRole('ADMIN') or hasRole('BILLING')")
    public ResponseEntity<ApiResponse<Invoice>> markAsPaid(@PathVariable Long id) {
        Invoice invoice = billingService.markInvoiceAsPaid(id);
        return ResponseEntity.ok(ApiResponse.success(invoice, "Invoice marked as paid"));
    }
}
