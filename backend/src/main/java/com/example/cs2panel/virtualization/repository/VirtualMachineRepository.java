package com.example.cs2panel.virtualization.repository;

import com.example.cs2panel.virtualization.entity.VirtualMachine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface VirtualMachineRepository extends JpaRepository<VirtualMachine, Long> {
    Optional<VirtualMachine> findByUuid(UUID uuid);
    List<VirtualMachine> findByOwnerId(Long ownerId);
    List<VirtualMachine> findByNodeId(Long nodeId);
    List<VirtualMachine> findByStatus(String status);
}
