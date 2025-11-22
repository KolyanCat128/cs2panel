package com.example.cs2panel.billing.service;

import com.example.cs2panel.billing.entity.BillingPlan;
import com.example.cs2panel.billing.entity.Invoice;
import com.example.cs2panel.billing.entity.InvoiceItem;
import com.example.cs2panel.billing.repository.BillingPlanRepository;
import com.example.cs2panel.billing.repository.InvoiceRepository;
import com.example.cs2panel.auth.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class BillingService {

    private final BillingPlanRepository planRepository;
    private final InvoiceRepository invoiceRepository;

    public List<BillingPlan> getAllPlans() {
        return planRepository.findByActiveTrue();
    }

    public BillingPlan getPlanById(Long id) {
        return planRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Plan not found"));
    }

    @Transactional
    public Invoice createInvoice(User user, BillingPlan plan) {
        String invoiceNumber = generateInvoiceNumber();

        BigDecimal subtotal = plan.getPrice();
        BigDecimal tax = subtotal.multiply(new BigDecimal("0.0")); // Configure tax rate
        BigDecimal total = subtotal.add(tax);

        Invoice invoice = Invoice.builder()
                .invoiceNumber(invoiceNumber)
                .user(user)
                .status("PENDING")
                .subtotal(subtotal)
                .tax(tax)
                .total(total)
                .currency(plan.getCurrency())
                .dueDate(LocalDate.now().plusDays(14))
                .build();

        InvoiceItem item = InvoiceItem.builder()
                .description(plan.getName() + " - " + plan.getBillingCycle())
                .quantity(1)
                .unitPrice(plan.getPrice())
                .amount(plan.getPrice())
                .build();

        invoice.addItem(item);

        invoice = invoiceRepository.save(invoice);
        log.info("Invoice created: {} for user: {}", invoiceNumber, user.getUsername());

        return invoice;
    }

    @Transactional
    public Invoice markInvoiceAsPaid(Long invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));

        invoice.setStatus("PAID");
        invoice.setPaidAt(LocalDateTime.now());

        return invoiceRepository.save(invoice);
    }

    public List<Invoice> getUserInvoices(Long userId) {
        return invoiceRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    private String generateInvoiceNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return "INV-" + timestamp;
    }

    public byte[] generateInvoicePdf(Long invoiceId) {
        // TODO: Implement PDF generation using iText
        Invoice invoice = invoiceRepository.findById(invoiceId)
                .orElseThrow(() -> new RuntimeException("Invoice not found"));

        log.info("Generating PDF for invoice: {}", invoice.getInvoiceNumber());
        // PDF generation implementation
        return new byte[0];
    }
}
