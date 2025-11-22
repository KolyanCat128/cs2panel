package com.example.cs2panel.billing.repository;

import com.example.cs2panel.billing.entity.BillingPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BillingPlanRepository extends JpaRepository<BillingPlan, Long> {
    List<BillingPlan> findByActiveTrue();
    List<BillingPlan> findByPlanType(String planType);
}
