package com.example.cs2panel.gameserver.repository;

import com.example.cs2panel.gameserver.entity.CS2Server;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CS2ServerRepository extends JpaRepository<CS2Server, Long> {
    List<CS2Server> findByOwnerId(Long ownerId);
    List<CS2Server> findByNodeId(Long nodeId);
    List<CS2Server> findByStatus(String status);
}
